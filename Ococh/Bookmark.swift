//
//  Bookmark.swift
//  Ococh
//
//  Created by Kristofer Younger on 9/22/22.
//

import Foundation

import SwiftUI

/**
 This is the view-facing `Bookmark` struct. Views should have no idea that this struct is
 backed up by a CoreData Managed Object: `BookmarkMO`. The `DataManager`
 handles keeping this in sync via `NSFetchedResultsControllerDelegate`.
 */
struct Bookmark: Identifiable, Hashable {
    var id: UUID
    var title: String
    var link: String
    var timestamp: Date
    var blob: Data
    
    init(title: String = "", link: String = "",
         date: Date = Date(), blob: Data = Data()) {
        self.id = UUID()
        self.title = title
        self.link = link
        self.timestamp = date
        self.blob = blob
    }
}
