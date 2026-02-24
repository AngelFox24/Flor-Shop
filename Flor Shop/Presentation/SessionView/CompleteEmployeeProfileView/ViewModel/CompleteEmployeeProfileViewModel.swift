import Foundation
import _PhotosUI_SwiftUI
import FlorShopDTOs

@Observable
final class CompleteEmployeeProfileViewModel {
    var fields = CompleteEmployeeProfileFields()
    var selectedLocalImage: UIImage?
    var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
    private let saveImageUseCase: SaveImageUseCase
    private let createEmployeeUseCase: CreateEmployeeUseCase
    private let emptyCartUseCase: EmptyCartUseCase
    init(
        saveImageUseCase: SaveImageUseCase,
        createEmployeeUseCase: CreateEmployeeUseCase,
        emptyCartUseCase: EmptyCartUseCase
    ) {
        self.saveImageUseCase = saveImageUseCase
        self.createEmployeeUseCase = createEmployeeUseCase
        self.emptyCartUseCase = emptyCartUseCase
    }
    func completeEmployeeProfile() async throws {
        let employee = self.getEmployee()
        try await self.createEmployeeUseCase.execute(employee: employee)
        //sleep 3 seconds
        try await Task.sleep(nanoseconds: 3_000_000_000)
        try await self.emptyCartUseCase.createCartIfNotExists()
    }
    private func getEmployee() -> Employee {
        return Employee(
            id: UUID(),
            employeeCic: nil,//nil porque es completar registro
            name: self.fields.name,
            email: self.fields.email,
            lastName: self.fields.lastName,
            role: self.fields.role,
            active: true,
            phoneNumber: self.fields.phone
        )
    }
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    print("Imagen vacia")
                    return
                }
                let optimizedImage = try self.saveImageUseCase.getOptimizedImage(uiImage: uiImage)
                await MainActor.run {
                    print("Se le asigno la imagen")
                    self.fields.imageUrl = ""
                    self.selectedLocalImage = optimizedImage
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

struct CompleteEmployeeProfileFields {
    var isShowingPicker = false
    var imageUrl: String = ""
    var name: String = ""
    var lastName: String = ""
    var email: String = ""
    var phone: String = ""
    var role: UserSubsidiaryRole = .employee
}
