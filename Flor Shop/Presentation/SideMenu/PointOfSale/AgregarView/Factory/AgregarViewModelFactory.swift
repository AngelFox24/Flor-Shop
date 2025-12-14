import Foundation

struct AgregarViewModelFactory {
    static func getAgregarViewModel(sessionContainer: SessionContainer) -> AgregarViewModel {
        return AgregarViewModel(
            saveProductUseCase: getSaveProductUseCase(sessionContainer: sessionContainer),
            saveImageUseCase: getSaveImageUseCase(sessionContainer: sessionContainer),
            exportProductsUseCase: getExportProductsUseCase(sessionContainer: sessionContainer),
            importProductsUseCase: getImportProductsUseCase(sessionContainer: sessionContainer),
            getProductsUseCase: getProductsUseCase(sessionContainer: sessionContainer)
        )
    }
    //Use cases
    static private func getSaveProductUseCase(sessionContainer: SessionContainer) -> SaveProductUseCase {
        return SaveProductInteractor(
            productRepository: sessionContainer.productRepository,
            imageRepository: sessionContainer.imageRepository
        )
    }
    static private func getSaveImageUseCase(sessionContainer: SessionContainer) -> SaveImageUseCase {
        return SaveImageInteractor(
            imageRepository: sessionContainer.imageRepository
        )
    }
    static private func getExportProductsUseCase(sessionContainer: SessionContainer) -> ExportProductsUseCase {
        return ExportProductsInteractor(
            productRepository: sessionContainer.productRepository
        )
    }
    static private func getImportProductsUseCase(sessionContainer: SessionContainer) -> ImportProductsUseCase {
        return ImportProductsInteractor(
            imageRepository: sessionContainer.imageRepository,
            productRepository: sessionContainer.productRepository
        )
    }
    static private func getProductsUseCase(sessionContainer: SessionContainer) -> GetProductsUseCase {
        return GetProductInteractor(productRepository: sessionContainer.productRepository)
    }
}
