//
//  GHUserViewModel.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 24/08/23.
//

import Foundation
import CloudKit

class GHUserViewModel: ObservableObject{
    
    private var database: CKDatabase
    private var container: CKContainer
    
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
 
    func fetchItems(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Struct", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "login", ascending: false)]
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
}
    
    
//    func fetch(){
//
//        var users: [GitHubUser] = []
//
//        let query = CKQuery(recordType: "Struct", predicate: NSPredicate(value: true))
//
//        database.fetch(withQuery: query) { result in
//            switch result{
//            case .success(let result):
//                result.matchResults.compactMap { $0.1 }
//                    .forEach{
//                    switch $0 {
//                    case .success(let record):
//                        if let ghUser = GitHubUser.translate(record) {
//                            users.append(ghUser)
//                        }
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//                DispatchQueue.main.async {
//                    self.users = users.map(userViewModel.init)
//                }
//
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//        }
//    }
//
//}
//
//struct userViewModel{
//
//    let ghUser: GitHubUser
//
//    var login: String {
//        ghUser.login
//    }
//
//    var avatarUrl: String{
//        ghUser.avatarUrl
//    }
//
//    var bio: String{
//        ghUser.bio ?? "bio not found 😔"
//    }
//
//}
