//
//  DataController.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 18/08/23.
//

import Foundation
import CoreData

class DataController: ObservableObject{
    let container = NSPersistentContainer(name: "GHUserModel")
    
    init(){
        container.loadPersistentStores { desc, error in
            if let error = error{
                print("Error \(error.localizedDescription), unable to load data")
            }
        }
    }
    
    func save(context: NSManagedObjectContext){
        do{
            try context.save()
        } catch {
            print("Error saving, try checking your storage")
        }
    }
    
    func addUser(login:String, avatarUrl: String, bio: String, context: NSManagedObjectContext){
        let user = GHUser(context: context)
        
        user.login = login
        user.avatarUrl = avatarUrl
        user.bio = bio
        
        save(context: context)
    }
    
    func delete(user:GHUser, context: NSManagedObjectContext){
        context.delete(user)
    }
}
