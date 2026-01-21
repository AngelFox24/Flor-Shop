import Foundation
import SwiftUI
import FlorShopDTOs

protocol LocalImageManager {
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage
}

final class LocalImageManagerImpl: LocalImageManager {
    let className = "[LocalImageManager]"
    let fileManager: LocalImageFileManager
    init(
        fileManager: LocalImageFileManager
    ) {
        self.fileManager = fileManager
    }
    func getOptimizedImage(uiImage: UIImage) throws -> UIImage {
        return try self.fileManager.getEfficientImage(uiImage: uiImage)
    }
}
