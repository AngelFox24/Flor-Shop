//
//  ImageURLDTO.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct ImageURLDTO: Codable {
    let id: UUID
    let imageUrl: String
    let imageHash: String
    let imageData: Data?
    let createdAt: String
    let updatedAt: String
}

extension ImageURLDTO {
    func toImageUrl() -> ImageUrl {
        return ImageUrl(
            id: id,
            imageUrl: imageUrl,
            imageHash: imageHash,
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
}
