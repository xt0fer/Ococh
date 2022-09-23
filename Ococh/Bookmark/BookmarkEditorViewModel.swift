//
//  BookmarkEditorViewModel.swift
//  Ococh
//
//  Created by Kristofer Younger on 9/22/22.
//

import Foundation

import SwiftUI
import Combine

@MainActor
final class BookmarkEditorViewModel: ObservableObject {
    
    @Published var editingBookmark: Bookmark
    
    @Published private var dataManager: DataManager
    
    var anyCancellable: AnyCancellable? = nil
    
    init(bookmark: Bookmark?, dataManager: DataManager = DataManager.shared) {
        if let bookmark = bookmark {
            self.editingBookmark = bookmark
        } else {
            self.editingBookmark = Bookmark()
        }
        self.dataManager = dataManager
        anyCancellable = dataManager.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }
    
    func saveBookmark() {
        dataManager.updateAndSave(bookmark: editingBookmark)
    }
    
}

extension StringProtocol {

    @inline(__always)
    var trailingSpacesTrimmed: Self.SubSequence {
        var view = self[...]

        while view.last?.isWhitespace == true {
            view = view.dropLast()
        }

        return view
    }
}
