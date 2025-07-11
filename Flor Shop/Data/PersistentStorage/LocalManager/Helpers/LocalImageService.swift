//
//  LocalImageService.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/06/2025.
//

import Foundation
import CoreData

protocol LocalImageService {
    func save(context: NSManagedObjectContext, image: ImageUrl?) throws -> Tb_ImageUrl?
}

struct LocalImageServiceImpl: LocalImageService {
    ///Guarda la imagen en Core Data validando:
    ///- 1: El Id (si es remoto deberia encontrarlo por este metodo o sino crearlo)
    ///- 2: El Hash (si es remoto y lo encuentra por este metodo puede que sea un error de sincronizacion)
    ///- 3: La URL (si es remoto y lo encuentra por este metodo puede que sea un error de sincronizacion)
    ///en caso no encuentre por ningunos de estos metodos debe crear una nueva entidad
    func save(context: NSManagedObjectContext, image: ImageUrl?) throws -> Tb_ImageUrl? {
        guard let image = image else {
            return nil
        }
        try validateImage(image: image)
        if let imageEntity = self.findById(context: context, id: image.id) {
            imageEntity.updatedAt = image.updatedAt
            return imageEntity
        } else if let imageEntity = try self.findByHash(context: context, hash: image.imageHash) {
            imageEntity.updatedAt = image.updatedAt
            return imageEntity
        } else if let imageEntity = try self.findByUrl(context: context, url: image.imageUrl) {
            imageEntity.updatedAt = image.updatedAt
            return imageEntity
        } else {
            let newImageEntity = Tb_ImageUrl(context: context)
            newImageEntity.idImageUrl = image.id
            newImageEntity.imageUrl = image.imageUrl
            newImageEntity.imageHash = image.imageHash
            newImageEntity.createdAt = image.createdAt
            newImageEntity.updatedAt = image.updatedAt
            return newImageEntity
        }
    }
    private func validateImage(image: ImageUrl) throws {
        ///Todas las imagenes deben tener URL, incluso las que son cargadas del movil, en este caso la URL representaria la direccion donde se almacena la imagen en local.
        let url = image.imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        guard url != "" else {
            throw LocalStorageError.invalidInput("La URL no es valida")
        }
        ///En caso el Hash venga vacio
        let hash = image.imageHash.trimmingCharacters(in: .whitespacesAndNewlines)
        guard hash != "" else {
            throw LocalStorageError.invalidInput("El Hash no puede estar vacio")
        }
    }
    private func findById(context: NSManagedObjectContext, id: UUID) -> Tb_ImageUrl? {
        let fetchRequest: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idImageUrl == %@", id.uuidString)
        return try? context.fetch(fetchRequest).first
    }
    private func findByHash(context: NSManagedObjectContext, hash: String) throws -> Tb_ImageUrl? {
        let fetchRequest: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imageHash == %@", hash)
        return try? context.fetch(fetchRequest).first
    }
    private func findByUrl(context: NSManagedObjectContext, url: String) throws -> Tb_ImageUrl? {
        let fetchRequest: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", url)
        return try? context.fetch(fetchRequest).first
    }
}
