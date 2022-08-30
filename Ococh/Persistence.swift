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
        container.viewContext.refreshAllObjects()
        
        return container

    }()

    //let container = NSPersistentContainer(name: "Ococh")
//    lazy var container: NSPersistentCloudKitContainer = {
//        Foundation.NSLog(">>> lazy setup of SharedCore persistentContainer")
//        NotificationCenter.default.post(name: Notification.Name("starting up cloudkit"), object: nil, userInfo: nil)
//
//        let container = NSPersistentCloudKitContainer(name: PersistenceController.containerName)
//
//        init(inMemory: Bool = false) {
//            container = NSPersistentCloudKitContainer(name: "Ococh")
//            if inMemory {
//                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
//            }
//            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//                if let error = error as NSError? {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                    /*
//                     Typical reasons for an error here include:
//                     * The parent directory does not exist, cannot be created, or disallows writing.
//                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                     * The device is out of space.
//                     * The store could not be migrated to the current model version.
//                     Check the error message to determine what the actual problem was.
//                     */
//                    fatalError("Unresolved error \(error), \(error.userInfo)")
//                }
//                storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
//                storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//
//            })
//
//            container.viewContext.automaticallyMergesChangesFromParent = true
//
//        }
//    }()
    
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
        return Bookmark(title: "A URL", link: "https://tioga.digital", insertIntoManagedObjectContext: vc)
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
        return []
    }
}

//public extension URL {
//    
//    /// Returns a URL for the given app group and database pointing to the sqlite database.
//    static func storeURL(for appGroup: String, databaseName: String) -> URL {
//        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
//            fatalError("Shared file container could not be created.")
//        }
//        
//        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
//    }
//}
//
//extension NSPersistentContainer {
//    
//    /// Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
//    func viewContextDidSaveExternally() {
//        // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness intervall of -1 the cache never invalidates.
//        // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
//        viewContext.stalenessInterval = 0
//        viewContext.refreshAllObjects()
//        viewContext.stalenessInterval = -1
//    }
//}
//
//extension NSPersistentContainer {
//    // Configure change event handling from external processes.
//    func observeAppExtensionDataChanges() {
//        DarwinNotificationCenter.shared.addObserver(self, for: .didSaveManagedObjectContextExternally, using: { [weak self] (_) in
//            // Since the viewContext is our root context that's directly connected to the persistent store, we need to update our viewContext.
//            self?.viewContext.perform {
//                self?.viewContextDidSaveExternally()
//            }
//        })
//    }
//}
//
//extension DarwinNotification.Name {
//    private static let appIsExtension = Bundle.main.bundlePath.hasSuffix(".appex")
//    
//    /// The relevant DarwinNotification name to observe when the managed object context has been saved in an external process.
//    static var didSaveManagedObjectContextExternally: DarwinNotification.Name {
//        if appIsExtension {
//            return appDidSaveManagedObjectContext
//        } else {
//            return extensionDidSaveManagedObjectContext
//        }
//    }
//    
//    /// The notification to post when a managed object context has been saved and stored to the persistent store.
//    static var didSaveManagedObjectContextLocally: DarwinNotification.Name {
//        if appIsExtension {
//            return extensionDidSaveManagedObjectContext
//        } else {
//            return appDidSaveManagedObjectContext
//        }
//    }
//    
//    /// Notification to be posted when the shared Core Data database has been saved to disk from an extension. Posting this notification between processes can help us fetching new changes when needed.
//    private static var extensionDidSaveManagedObjectContext: DarwinNotification.Name {
//        return DarwinNotification.Name("com.tiogadigital.ococh.extension-did-save")
//    }
//    
//    /// Notification to be posted when the shared Core Data database has been saved to disk from the app. Posting this notification between processes can help us fetching new changes when needed.
//    private static var appDidSaveManagedObjectContext: DarwinNotification.Name {
//        return DarwinNotification.Name("com.tiogadigital.ococh.app-did-save")
//    }
//}
