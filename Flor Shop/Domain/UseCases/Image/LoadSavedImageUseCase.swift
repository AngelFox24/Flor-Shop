//
//  LoadSavedImageUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/24.
//
import Foundation
import SwiftUI

protocol LoadSavedImageUseCase {
    func execute(id: UUID) -> UIImage?
}

final class LoadSavedImageInteractor: LoadSavedImageUseCase {
    
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    func execute(id: UUID) -> UIImage? {
        return self.imageRepository.loadSavedImage(id: id)
    }
}
