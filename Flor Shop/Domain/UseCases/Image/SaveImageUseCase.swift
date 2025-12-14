import Foundation
import SwiftUI

protocol SaveImageUseCase {
    func execute(uiImage: UIImage) async throws -> URL
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage
}

final class SaveImageInteractor: SaveImageUseCase {
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    func execute(uiImage: UIImage) async throws -> URL {
        return try await self.imageRepository.saveImage(uiImage: uiImage)
    }
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage {
        try self.imageRepository.getOptimizedImage(uiImage: uiImage)
    }
}
