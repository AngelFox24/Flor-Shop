//
//  LocalImageManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 25/08/23.
//

import Foundation
import CoreData

protocol ImageManager {
    func deleteUnusedImages() async
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
    func deleteUnusedImages() async {
        async let imagesLocal = getImagesIdsLocal()
        let imagesCoreData = await getImagesIdsCoreData()
        let imagesToDelete = await imagesLocal.filter { !imagesCoreData.contains($0) }
        await deleteImageFile(imagesNames: imagesToDelete)
    }
    func deleteImageFile(imagesNames: [String]) async {
        let fileManager = FileManager.default
        guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            
            for imageURL in directoryContents {
                if imageURL.pathExtension.lowercased() == "jpg" || imageURL.pathExtension.lowercased() == "jpeg" || imageURL.pathExtension.lowercased() == "png" {
                    let imageRes = imageURL
                    let imageName = imageRes.deletingPathExtension()
                    let imageNameString = imageName.lastPathComponent
                    if imagesNames.contains(imageNameString) {
                        try fileManager.removeItem(at: imageRes)
                    }
                }
            }
        } catch {
            print("Error al borrar imagenes sin uso")
        }
    }
    func getImagesIdsLocal() async -> [String] {
        var imagesNames: [String] = []
        let fileManager = FileManager.default
        guard let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return []
        }
        let imagesDirectory = libraryDirectory.appendingPathComponent("Images")
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            for imageURL in directoryContents {
                if imageURL.pathExtension.lowercased() == "jpg" || imageURL.pathExtension.lowercased() == "jpeg" || imageURL.pathExtension.lowercased() == "png" {
                    let imagename = imageURL.deletingPathExtension()
                    imagesNames.append(imagename.lastPathComponent)
                }
            }
            return imagesNames
        } catch {
            return []
        }
    }
    func getImagesIdsCoreData() async -> [String] {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Tb_ImageUrl")
        
        let predicate = NSPredicate(format: "idImageUrl != nil")
        fetchRequest.predicate = predicate
        
        fetchRequest.propertiesToFetch = ["idImageUrl"]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            print("Se intenta retornar la lista")
            //return try self.mainContext.fetch(fetchRequest)
            let res = try self.mainContext.fetch(fetchRequest)
            let ret = res.compactMap { value in
                guard let id = value["idImageUrl"] as? UUID else {
                    return ""
                }
                return id.uuidString
            }
            return ret.compactMap { $0.isEmpty ? nil : $0 }
        } catch {
            print("Error borrar imagenes sin uso: \(error.localizedDescription)")
            return []
        }
    }
}
