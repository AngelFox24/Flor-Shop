//
//  ImageRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/24.
//

import Foundation
import SwiftUI

protocol ImageRepository {
    func deleteUnusedImages() async
    func loadSavedImage(id: UUID) -> UIImage?
    func downloadImage(url: URL) async -> UIImage?
    func saveImage(id: UUID, image: UIImage, resize: Bool) -> String
}

class ImageRepositoryImpl: ImageRepository {
    let manager: ImageManager
    // let remote:  remoto, se puede implementar el remoto aqui
    init(manager: ImageManager) {
        self.manager = manager
    }
    func deleteUnusedImages() async {
        await self.manager.deleteUnusedImages()
    }
    func loadSavedImage(id: UUID) -> UIImage? {
        return self.manager.loadSavedImage(id: id)
    }
    func downloadImage(url: URL) async -> UIImage? {
        return await self.manager.downloadImage(url: url)
    }
    func saveImage(id: UUID, image: UIImage, resize: Bool) -> String {
        return self.manager.saveImage(id: id, image: image, resize: resize)
    }
}
