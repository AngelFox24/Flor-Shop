import Foundation
import FlorShopDTOs
import FlorShopNetworking

protocol RemoteImageManager {
    func save(imageData: Data) async throws -> URL
}

final class RemoteImageManagerImpl: RemoteImageManager {
    func save(imageData: Data) async throws -> URL {
        let request = FlorShopImagesApiRequest.saveImage(image: ImageServerDTO(imageData: imageData))
        let image: ImageClientDTO = try await NetworkManager.shared.perform(request, decodeTo: ImageClientDTO.self)
        guard let url = URL(string: image.imageURL) else {
            throw LocalStorageError.invalidInput("[RemoteImageManagerImpl] bad image url")
        }
        return url
    }
}
