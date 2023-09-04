//
//  LocalImageManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/08/23.
//

import Foundation
import CoreData

protocol ImageManager {
}

class LocalImageManager: ImageManager {
    let mainContext: NSManagedObjectContext
    init(mainContext: NSManagedObjectContext) {
        self.mainContext = mainContext
    }
    func saveData() {
        do {
            try self.mainContext.save()
        } catch {
            print("Error al guardar en LocalImageManager: \(error)")
        }
    }
    func rollback() {
        self.mainContext.rollback()
    }
    //C - Create
    func createImage(image: ImageUrl) -> ImageUrl {
        return ImageUrl.getDummyImage()
    }
    //R - Read
    func getImage(image: ImageUrl) -> ImageUrl {
        return ImageUrl.getDummyImage()
    }
    //U - Update
    func updateImage(image: ImageUrl) {
    }
    //D - Delete
    func deleteImage(image: ImageUrl) {
    }
}