//
//  Swift_APIsApp.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 17/08/23.
//

import SwiftUI
import CloudKit

@main
struct Swift_APIsApp: App {

    let container = CKContainer(identifier: "iCloud.SwiftUI.API.Learning")
    
    var body: some Scene {
        WindowGroup {
            ContentView(vm: GHUserViewModel(container: container))
        }
    }
}
