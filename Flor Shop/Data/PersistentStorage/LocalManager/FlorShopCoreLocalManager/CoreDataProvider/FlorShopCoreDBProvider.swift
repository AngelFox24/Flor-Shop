import Foundation
import CoreData

class FlorShopCoreDBProvider {
    static let shared: FlorShopCoreDBProvider = FlorShopCoreDBProvider()
    private var persistentContainer: NSPersistentContainer
    private init() {
        persistentContainer = NSPersistentContainer(name: "FlorShopCoreDB")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to initialize data \(error)")
            }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.undoManager = nil
        persistentContainer.viewContext.shouldDeleteInaccessibleFaults = true
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    var persistContainer: NSPersistentContainer {
        persistentContainer
    }
}
