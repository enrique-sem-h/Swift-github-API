//
//  Swift_APIsApp.swift
//  Swift-APIs
//
//  Created by Enrique Carvalho on 17/08/23.
//

import SwiftUI

@main
struct Swift_APIsApp: App {
    @StateObject private var dataControler = DataController()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataControler.container.viewContext)
        }
    }
}
