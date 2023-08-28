//
//  Struct.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 18/08/23.
//

import Foundation
import CloudKit

struct GitHubUser: Hashable{
    var record: CKRecord?
    var login: String
    var avatarUrl: String
    var bio: String?
    
    init(record: CKRecord? = nil, login: String, avatarUrl: String, bio: String? = nil) {
        self.record = record
        self.login = login
        self.avatarUrl = avatarUrl
        self.bio = bio
    }
    
    func toDict() -> [String : Any]{
        return ["login" : login, "avatarUrl" : avatarUrl, "bio" : bio]
    }
    
    static func translate(_ record: CKRecord) -> GitHubUser?{
        
        guard let login = record.value(forKey: "login") as? String, let avatarUrl = record.value(forKey: "avatarUrl") as? String, let bio = record.value(forKey: "bio") as? String else { return nil }
        
        return GitHubUser(login: login, avatarUrl: avatarUrl, bio: bio)
    }
}

