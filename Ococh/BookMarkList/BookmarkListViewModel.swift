//
//  BookmakListView.swift
//  Ococh
//
//  Created by Kristofer Younger on 9/22/22.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class BookmarkListViewModel: ObservableObject {
    
    @Published var showEditor = false
    @Published var isFiltered = false
    @Published var isSorted = false
    
    @Published private var dataManager: DataManager
    
    var anyCancellable: AnyCancellable? = nil
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
        anyCancellable = dataManager.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    var bookmarks: [Bookmark] {
        dataManager.bookmarksArray
    }
        
    func delete(at offsets: IndexSet) {
        for index in offsets {
            dataManager.delete(bookmark: bookmarks[index])
        }
    }
    
    
    func toggleSort() {
        isSorted.toggle()
        if isSorted {
            dataManager.fetchBookmarks(sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)])
        } else {
            dataManager.fetchBookmarks(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)])
        }
    }
    
    func fetchTodos() {
        dataManager.fetchBookmarks()
    }
    
    
}
