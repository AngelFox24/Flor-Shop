import Foundation
import FlorShopDTOs

protocol RemoteImageManager {
    func save(imageData: Data) async throws -> URL
}

final class RemoteImageManagerImpl: RemoteImageManager {
    func save(imageData: Data) async throws -> URL {
        let request = FlorShopImagesApiRequest.saveImage(image: ImageServerDTO(imageData: imageData))
        let image: ImageClientDTO = try await NetworkManager.shared.perform(request, decodeTo: ImageClientDTO.self)
        guard let url = URL(string: image.imageURL) else {
            throw NetworkError.badURL
        }
        return url
    }
}
