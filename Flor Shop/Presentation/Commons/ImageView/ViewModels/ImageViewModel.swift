//
//  ImageViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/04/23.
//

import Foundation
import SwiftUI
import CoreData

class ImageViewModel: ObservableObject {
    
    @Published var image: Image?
    
    //Managers
    private let mainContext: NSManagedObjectContext
    private let imageManager: ImageManager
    //Repositories
    private let imageRepository: ImageRepositoryImpl
    //UseCases
    private let deleteUnusedImagesUseCase: DeleteUnusedImagesUseCase
    private let loadSavedImageUseCase: LoadSavedImageUseCase
    private let downloadImageUseCase: DownloadImageUseCase
    private let saveImageUseCase: SaveImageUseCase
    
    init() {
        self.mainContext = CoreDataProvider.shared.viewContext
        
        self.imageManager = LocalImageManager(mainContext: self.mainContext)
        self.imageRepository = ImageRepositoryImpl(manager: self.imageManager)
        self.deleteUnusedImagesUseCase = DeleteUnusedImagesInteractor(imageRepository: self.imageRepository)
        self.loadSavedImageUseCase = LoadSavedImageInteractor(imageRepository: self.imageRepository)
        self.downloadImageUseCase = DownloadImageInteractor(imageRepository: self.imageRepository)
        self.saveImageUseCase = SaveImageInteractor(imageRepository: self.imageRepository)
    }
    
    func loadImage(id: UUID, url: String?) async {
        print("Se intenta cargar imagen \(id)")
        //Fijarse si hay en local
        if let savedImage = self.loadSavedImageUseCase.execute(id: id) {
            await MainActor.run {
                print("Se carga imagen local")
                self.image = Image(uiImage: savedImage)
            }
        } else {
            //Sino descargar
            guard let urlNN = url, let urlT = URL(string: urlNN) else {
                return
            }
            print("Se intenta descargar imagen")
            let imageOp = await self.downloadImageUseCase.execute(url: urlT)
            //let dataOp = ImageViewModel.resizeImage(data: dataNN, maxWidth: 200, maxHeight: 200)
            if let uiImageNN = imageOp {
                await MainActor.run {
                    print("Se carga imagen descargada")
                    self.image = Image(uiImage: uiImageNN)
                }
                //self.saveImageUseCase.execute(id: id, image: uiImageNN, resize: false)
                self.saveImageUseCase.execute(idImage: id, image: uiImageNN)
            }
        }
    }
}
