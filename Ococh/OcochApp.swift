//
//  OcochApp.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import SwiftUI

@main
struct OcochApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var dataManager = DataManager.shared
    

    var body: some Scene {
#if InitializeCloudKitSchema
WindowGroup {
    Text("Initializing CloudKit Schema...").font(.title)
    Text("Stop after Xcode says 'no more requests to execute', " +
         "then check with CloudKit Console if the schema is created correctly.").padding()
}
#else
        WindowGroup {
            BookmarkListView()
       }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                print("Active")
                //dataManager.fetchBookmarks()
            case .inactive:
                print("Inactive")
                dataManager.saveData()
            case .background:
                print("background")
                dataManager.saveData()
            default:
                print("unknown")
            }
        }
#endif

    }
}
