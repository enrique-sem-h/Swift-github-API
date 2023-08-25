//
//  ErrorHandler.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 18/08/23.
//

import Foundation

enum GHError: Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
