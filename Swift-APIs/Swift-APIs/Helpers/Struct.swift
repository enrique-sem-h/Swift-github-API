//
//  Struct.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 18/08/23.
//

import Foundation

struct GitHubUser: Codable{
    var login: String
    var avatarUrl: String
    var bio: String?
}
