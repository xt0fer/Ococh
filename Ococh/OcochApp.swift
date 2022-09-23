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
    }
}
