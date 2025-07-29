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
