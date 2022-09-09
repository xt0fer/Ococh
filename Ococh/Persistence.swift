//
//  Persistence.swift
//  Ococh
//
//  Created by Kristofer Younger on 8/29/22.
//

import CoreData

// setup as Class

public class Storage {
    static let shared = Storage()
    
    static let containerName = "Ococh"

    // container should be lazy
    
    lazy var container: NSPersistentCloudKitContainer = {
        Foundation.NSLog(">>> lazy setup of Storage persistentContainer")
        NotificationCenter.default.post(name: Notification.Name("starting up cloudkit"), object: nil, userInfo: nil)
        
        let container = NSPersistentCloudKitContainer(name: Storage.containerName)

        //Foundation.NSLog("KKYY Loading: container.loadPersistentStores")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                Foundation.NSLog("Unresolved error in loading cloudkit container \(error), \(error.userInfo)")
                    // SEE error notes below.
            }
            //Foundation.NSLog("KKYY Store description: \(storeDescription)")
            guard let description = container.persistentStoreDescriptions.first else {
                    fatalError("###\(#function): Failed to retrieve a persistent store description.")
                }
            //important options.
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        })
        
        // important option and import refresh...
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        container.viewContext.refreshAllObjects()
        
        return container

    }()

    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Foundation.NSLog("unable to save \(error)")
            }
        }
    }
    
    func refresh() {
        let vc = container.viewContext
        vc.refreshAllObjects()
    }
    
    static var preview: Storage = {
        let result = Storage()
        let viewContext = result.container.viewContext
        for s in 0..<10 {
            let newItem = Bookmark(context: viewContext)
            newItem.timestamp = .now
            newItem.title = "Bookmark\(s)"
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

}

extension Bookmark {
    static func emptyBookmark() -> Bookmark {
        let vc = Storage.shared.container.viewContext
        return Bookmark(title: "Tioga Digital", link: "https://tioga.digital", insertIntoManagedObjectContext: vc)
    }
    
    convenience init(title: String, link: String, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        let entity = NSEntityDescription.entity(forEntityName: "Bookmark", in: context)!
        self.init(entity: entity, insertInto: context)
        self.title = title
        self.link = link
        self.id = UUID()
        self.timestamp = Date()
    }
    
    static func getAll() -> [Bookmark] {
        // Create a fetch request for a specific Entity type
        let fetchRequest: NSFetchRequest<Bookmark>
        fetchRequest = Bookmark.fetchRequest()

        // Get a reference to a NSManagedObjectContext
        let context = Storage.shared.container.viewContext

        // Fetch all objects of one Entity type
        do {
            let objects = try context.fetch(fetchRequest)
            print("KKYY getting books marks \(objects.count)")
            return objects
         } catch {
           let nserror = error as NSError
           fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
         }
        // return []
    }
}
