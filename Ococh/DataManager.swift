//
//  DataManager.swift
//  Ococh
//
//  Created by Kristofer Younger on 9/22/22.
//

import Foundation
import CoreData
import OrderedCollections

enum DataManagerType {
    case normal, preview, testing
}

class DataManager: NSObject, ObservableObject {
    
    static let shared = DataManager(type: .normal)
    static let preview = DataManager(type: .preview)
    static let testing = DataManager(type: .testing)
    
    @Published var bookmarks: OrderedDictionary<UUID, Bookmark> = [:]
    
    var bookmarksArray: [Bookmark] {
        Array(bookmarks.values)
    }
    
    
    fileprivate var managedObjectContext: NSManagedObjectContext
    let bookmarkFRC: NSFetchedResultsController<BookmarkMO>
    
    private init(type: DataManagerType) {
        switch type {
        case .normal:
            let persistentStore = PersistentStore()
            self.managedObjectContext = persistentStore.context
        case .preview:
            let persistentStore = PersistentStore(inMemory: true)
            self.managedObjectContext = persistentStore.context
            for i in 0..<10 {
                let newBookmark = BookmarkMO(context: managedObjectContext)
                newBookmark.title = "Bookmark \(i)"
                newBookmark.link = "https://ococh.com/bm/\(i)"
                newBookmark.timestamp = Date()
                newBookmark.id = UUID()
            }
            try? self.managedObjectContext.save()
        case .testing:
            let persistentStore = PersistentStore(inMemory: true)
            self.managedObjectContext = persistentStore.context
        }
        
        let bookmarkFR: NSFetchRequest<BookmarkMO> = BookmarkMO.fetchRequest()
        bookmarkFR.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        bookmarkFRC = NSFetchedResultsController(fetchRequest: bookmarkFR,
                                              managedObjectContext: managedObjectContext,
                                              sectionNameKeyPath: nil,
                                              cacheName: nil)
                
        super.init()
        
        // Initial fetch to populate bookmarks array
        bookmarkFRC.delegate = self
        try? bookmarkFRC.performFetch()
        if let newBookmarks = bookmarkFRC.fetchedObjects {
            self.bookmarks = OrderedDictionary(uniqueKeysWithValues: newBookmarks.map({ ($0.id!, Bookmark(bookmarkMO: $0)) }))
        }
        
    }
    
    func saveData() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                NSLog("KKYY Unresolved error saving context: \(error), \(error.userInfo)")
            }
        }
    }
}

extension DataManager: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let newBookmarks = controller.fetchedObjects as? [BookmarkMO] {
            self.bookmarks = OrderedDictionary(uniqueKeysWithValues: newBookmarks.map({ ($0.id!, Bookmark(bookmarkMO: $0)) }))
        }
    }
    
    private func fetchFirst<T: NSManagedObject>(_ objectType: T.Type, predicate: NSPredicate?) -> Result<T?, Error> {
        let request = objectType.fetchRequest()
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try managedObjectContext.fetch(request) as? [T]
            return .success(result?.first)
        } catch {
            return .failure(error)
        }
    }
    
    func fetchBookmarks(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) {
        if let predicate = predicate {
            bookmarkFRC.fetchRequest.predicate = predicate
        }
        if let sortDescriptors = sortDescriptors {
            bookmarkFRC.fetchRequest.sortDescriptors = sortDescriptors
        }
        try? bookmarkFRC.performFetch()
        if let newBookmarks = bookmarkFRC.fetchedObjects {
            self.bookmarks = OrderedDictionary(uniqueKeysWithValues: newBookmarks.map({ ($0.id!, Bookmark(bookmarkMO: $0)) }))
        }
    }
    
    func resetFetch() {
        bookmarkFRC.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        bookmarkFRC.fetchRequest.predicate = nil
        try? bookmarkFRC.performFetch()
        if let newBookmarks = bookmarkFRC.fetchedObjects {
            self.bookmarks = OrderedDictionary(uniqueKeysWithValues: newBookmarks.map({ ($0.id!, Bookmark(bookmarkMO: $0)) }))
        }
    }

}

//MARK: - Bookmark Methods
extension Bookmark {
    
    fileprivate init(bookmarkMO: BookmarkMO) {
        self.id = bookmarkMO.id ?? UUID()
        self.title = bookmarkMO.title ?? ""
        self.link = bookmarkMO.link ?? ""
        self.timestamp = bookmarkMO.timestamp ?? Date()
        self.blob = Data()
    }
}

extension DataManager {
    
    func updateAndSave(bookmark: Bookmark) {
        let predicate = NSPredicate(format: "id = %@", bookmark.id as CVarArg)
        let result = fetchFirst(BookmarkMO.self, predicate: predicate)
        switch result {
        case .success(let managedObject):
            if let bookmarkMo = managedObject {
                update(bookmarkMO: bookmarkMo, from: bookmark)
            } else {
                print("KKYY Saving new BookmarkMO")
                bookmarkMO(from: bookmark)
            }
        case .failure(_):
            print("KKYY Couldn't fetch BookmarkMO to save")
        }
        
        saveData()
    }
    
    func delete(bookmark: Bookmark) {
        let predicate = NSPredicate(format: "id = %@", bookmark.id as CVarArg)
        let result = fetchFirst(BookmarkMO.self, predicate: predicate)
        switch result {
        case .success(let managedObject):
            if let bookmarkMo = managedObject {
                managedObjectContext.delete(bookmarkMo)
            }
        case .failure(_):
            print("Couldn't fetch BookmarkMO to save")
        }
        saveData()
    }
    
    func getBookmark(with id: UUID) -> Bookmark? {
        return bookmarks[id]
    }
    
    private func bookmarkMO(from bookmark: Bookmark) {
        let bookmarkMO = BookmarkMO(context: managedObjectContext)
        bookmarkMO.id = bookmark.id
        update(bookmarkMO: bookmarkMO, from: bookmark)
    }
    
    private func update(bookmarkMO: BookmarkMO, from bookmark: Bookmark) {
        bookmarkMO.title = bookmark.title
        bookmarkMO.link = bookmark.link
        bookmarkMO.timestamp = bookmark.timestamp
    }
    
    ///Get's the BookmarkMO that corresponds to the bookmark. If no BookmarkMO is found, returns nil.
    private func getBookmarkMO(from bookmark: Bookmark?) -> BookmarkMO? {
        guard let bookmark = bookmark else { return nil }
        let predicate = NSPredicate(format: "id = %@", bookmark.id as CVarArg)
        let result = fetchFirst(BookmarkMO.self, predicate: predicate)
        switch result {
        case .success(let managedObject):
            if let bookmarkMO = managedObject {
                return bookmarkMO
            } else {
                return nil
            }
        case .failure(_):
            return nil
        }
        
    }
    
}


