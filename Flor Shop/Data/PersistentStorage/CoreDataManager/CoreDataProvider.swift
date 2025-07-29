import Foundation
import CoreData

class CoreDataProvider {
    static let shared: CoreDataProvider = CoreDataProvider()
    private var persistentContainer: NSPersistentContainer
    private init() {
        persistentContainer = NSPersistentContainer(name: "BDFlor")
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
