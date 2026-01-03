import Foundation

struct CompleteEmployeeProfileViewModelFactory {
    static func getViewModel() -> CompleteEmployeeProfileViewModel {
        return CompleteEmployeeProfileViewModel(
            saveImageUseCase: getSaveImageUseCase()
        )
    }
    static private func getSaveImageUseCase() -> SaveImageUseCase {
        return SaveImageInteractor(
            imageRepository: AppContainer.shared.imageRepository
        )
    }
}
