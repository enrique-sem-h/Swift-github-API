//
//  GHUserViewModel.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 24/08/23.
//

import Foundation
import SwiftUI
import CloudKit
import UserNotifications

class GHUserViewModel: ObservableObject{
    
    private var database: CKDatabase
    private var container: CKContainer
    
    @Published var isDoneFetching = false
    @Published var users: [GitHubUser] = []
    
    init(container: CKContainer) {
        self.container = container
        self.database = self.container.privateCloudDatabase
        fetchItems()
    }
    
    func saveUser(login: String, avatarUrl: String, bio: String?){
        
        let record = CKRecord(recordType: "Struct")
        let ghUser = GitHubUser(record: record,login: login, avatarUrl: avatarUrl, bio: bio)
        record.setValuesForKeys(ghUser.toDict())
        
        // saving to database
        self.database.save(record) { returnedRecord, returnedError in
            if let error = returnedError{
                print(error)
            } else {
                if let record = returnedRecord{
                    print("Saved - \(record)")
                }
            }
        }
    }
 
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Struct", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "login", ascending: true)]
        let queryOp = CKQueryOperation(query: query)
        
        var returnedUsers: [GitHubUser] = []
        
        queryOp.recordMatchedBlock = { returnedRecordID, returnedResult in
            switch returnedResult{
            case .success(let record):
                if let ghUser = GitHubUser.translate(record){
                    returnedUsers.append(GitHubUser(record: record, login: ghUser.login, avatarUrl: ghUser.avatarUrl, bio: ghUser.bio))
                }
                break
            case .failure(let error):
                print(error)
            }
            
        }
        queryOp.queryResultBlock = { [weak self] returnedResult in
            DispatchQueue.main.async {
                self?.users = returnedUsers
                self?.isDoneFetching = true
            }
        }
        
        addOp(operation: queryOp)
        
    }

    func addOp(operation: CKDatabaseOperation){
        CKContainer(identifier: "iCloud.SwiftUI.API.Learning").privateCloudDatabase.add(operation)
    }
 
    func del(indexSet: IndexSet){
        guard let index = indexSet.first else { return }
        
        let user = users[index]
        let record = user.record
        
        CKContainer(identifier: "iCloud.SwiftUI.API.Learning").privateCloudDatabase.delete(withRecordID: record!.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.users.remove(at: index)
            }
        }
    }
    
    func requestNotificationPermissions(){
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error{
                print(error.localizedDescription)
            } else if success{
                print("Success!")
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
            } else {
                print("There was an error with the authorization request")
            }
        }
    }
    
    func subscribeToNotifications(){
//        let options = CKQuerySubscription.Options()
//        options.
        
        let subscription = CKQuerySubscription(recordType: "Struct", predicate: NSPredicate(value: true), subscriptionID: "user-added-to-DB", options: .firesOnRecordCreation)
        subscription.zoneID = .default
        
        let notification = CKSubscription.NotificationInfo()
        notification.title = "A new user was added to your database"
        notification.alertBody = "Open the app to check more details"
        notification.soundName = "default"
        notification.shouldBadge = true
        
        subscription.notificationInfo = notification
        
        self.database.save(subscription) { returnedRecord, returnedError in
            if let error = returnedError{
                print(error)
            } else {
                print("succesfully subscribed to user notifications")
            }
        }
        
    }
}
