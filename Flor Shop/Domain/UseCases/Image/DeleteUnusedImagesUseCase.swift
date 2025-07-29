import Foundation

protocol DeleteUnusedImagesUseCase {
    
    func execute() async
}

final class DeleteUnusedImagesInteractor: DeleteUnusedImagesUseCase {
    
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func execute() async {
        await self.imageRepository.deleteUnusedImages()
    }
}
