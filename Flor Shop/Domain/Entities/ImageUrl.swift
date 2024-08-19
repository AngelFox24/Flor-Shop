//
//  ImageUrl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

struct ImageUrl: Identifiable, Codable {
    var id: UUID
    var imageUrl: String
    var imageHash: String
    let createdAt: Date
    let updatedAt: Date
}

extension ImageUrl {
    func toImageUrlEntity(context: NSManagedObjectContext) -> Tb_ImageUrl? {
        let filterAtt = NSPredicate(format: "(imageUrl == %@ AND imageUrl != '' AND imageUrl != nil) OR (imageHash == %@ AND imageHash != '' AND imageHash != nil)", imageUrl, imageHash)
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        request.predicate = filterAtt
        do {
            let imageUrlEntity = try context.fetch(request).first
            print("CoreData Extract Id: \(String(describing: imageUrlEntity?.idImageUrl?.uuidString)) Hash: \(String(describing: imageUrlEntity?.imageHash))")
            return imageUrlEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func toImageUrlDTO() -> ImageURLDTO {
        return ImageURLDTO(
            id: id,
            imageUrl: imageUrl,
            imageHash: imageHash,
            imageData: nil,
            createdAt: createdAt.description,
            updatedAt: updatedAt.description
        )
    }
}
