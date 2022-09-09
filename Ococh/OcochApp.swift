//
//  OcochApp.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI

@main
struct OcochApp: App {
    let persistenceController = Storage.shared

    var body: some Scene {
        WindowGroup {
            BookmarkListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        
    }
}
