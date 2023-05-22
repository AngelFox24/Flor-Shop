//
//  CoreDataProvider.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 20/05/23.
//

import Foundation
import CoreData

class CoreDataProvider {
    
    static let shared: CoreDataProvider = CoreDataProvider()
    private var persistentContainer: NSPersistentContainer
    
    private init() {
        
        persistentContainer = NSPersistentContainer(name: "BDFlor")
        persistentContainer.loadPersistentStores { description, error in
            if let error {
                fatalError("Unable to initialize data \(error)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var persistContainer:NSPersistentContainer {
        persistentContainer
    }
}
