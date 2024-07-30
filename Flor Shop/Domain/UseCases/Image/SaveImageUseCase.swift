//
//  SaveImageUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/24.
//

import Foundation
import SwiftUI

protocol SaveImageUseCase {
    func execute(idImage: UUID, image: UIImage) -> ImageUrl?
}

final class SaveImageInteractor: SaveImageUseCase {
    
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    @discardableResult
    func execute(idImage: UUID, image: UIImage) -> ImageUrl? {
        return self.imageRepository.save(idImage: idImage, image: image)
    }
}
