//
//  SaveImageUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/24.
//

import Foundation
import SwiftUI

protocol SaveImageUseCase {
    func execute(id: UUID, image: UIImage, resize: Bool) -> String
}

final class SaveImageInteractor: SaveImageUseCase {
    
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func execute(id: UUID, image: UIImage, resize: Bool = true) -> String {
        return self.imageRepository.saveImage(id: id, image: image, resize: resize)
    }
}
