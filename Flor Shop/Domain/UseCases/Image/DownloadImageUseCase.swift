//
//  DownloadImageUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/24.
//
import Foundation
import SwiftUI

protocol DownloadImageUseCase {
    func execute(url: URL) async -> UIImage?
}

final class DownloadImageInteractor: DownloadImageUseCase {
    
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func execute(url: URL) async -> UIImage? {
        return await self.imageRepository.downloadImage(url: url)
    }
}

