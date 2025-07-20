//
//  SaveImageUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 02/08/2024.
//

import Foundation
import SwiftUI

protocol GetImageUseCase {
    func execute(uiImage: UIImage) async throws -> ImageUrl
}

final class GetImageInteractor: GetImageUseCase {
    
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    func execute(uiImage: UIImage) async throws -> ImageUrl {
        return try await self.imageRepository.getImage(image: uiImage)
    }
}
