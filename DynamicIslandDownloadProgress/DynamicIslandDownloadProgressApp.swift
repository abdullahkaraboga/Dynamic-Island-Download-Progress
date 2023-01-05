//
//  DynamicIslandDownloadProgressApp.swift
//  DynamicIslandDownloadProgress
//
//  Created by Abdullah Karaboğa on 5.01.2023.
//

import SwiftUI

@main
struct DynamicIslandDownloadProgressApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
