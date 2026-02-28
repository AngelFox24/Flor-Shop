import Foundation
import SwiftUI
import _PhotosUI_SwiftUI
import FlorShopDTOs
import Kingfisher

enum EditEmployeeTransaction: Equatable {
    case none
    case edit(employeeCic: String)
}

@Observable
final class EditEmployeeProfileViewModel: AlertPresenting {
    var alert: Bool = false
    var alertInfo: AlertInfo?
    var isLoading: Bool = false
    var fields = EditEmployeeProfileFields()
    var selectedLocalImage: UIImage?
    var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
    var editEmployeeTransaction: EditEmployeeTransaction = .none
    private let saveImageUseCase: SaveImageUseCase
    private let createEmployeeUseCase: CreateEmployeeUseCase
    private let getEmployeesUseCase: GetEmployeesUseCase
    init(
        saveImageUseCase: SaveImageUseCase,
        createEmployeeUseCase: CreateEmployeeUseCase,
        getEmployeesUseCase: GetEmployeesUseCase
    ) {
        self.saveImageUseCase = saveImageUseCase
        self.createEmployeeUseCase = createEmployeeUseCase
        self.getEmployeesUseCase = getEmployeesUseCase
    }
    @MainActor
    func saveEmployeeTransaccion() {
        let employee = self.getEmployee()
        guard let employeeCic = employee.employeeCic else { return }
        self.editEmployeeTransaction = .edit(employeeCic: employeeCic)
    }
    @MainActor
    private func setEmployeeField(employee: Employee, isOwnProfile: Bool) async throws {
        if !isOwnProfile {
            self.fields.isNameDisable = true
            self.fields.isLastNameDisable = true
            self.fields.isPhoneDisable = true
            self.fields.isPickerDisable = true
        }
        self.fields.isEmailDisable = true
        self.fields.imageUrl = employee.imageUrl ?? ""
        self.fields.email = employee.email
        self.fields.lastName = employee.lastName ?? ""
        self.fields.phone = employee.phoneNumber ?? ""
        self.fields.role = employee.role
        self.fields.name = employee.name
        self.fields.employeeCic = employee.employeeCic ?? ""
        
        if let imageUrlString = employee.imageUrl,
           let imageUrl = URL(string: imageUrlString) {
            print("[EditEmployeeProfileViewModel] Se contruyo la url: \(imageUrl.absoluteString)")
            let processor = DownsamplingImageProcessor(size: CGSize(width: 200, height: 200))
            let serializer = FormatIndicatedCacheSerializer.png
            var result: RetrieveImageResult?
            do {
                result = try await KingfisherManager.shared.retrieveImage(
                    with: imageUrl,
                    options: [
                        .onlyFromCache,
                        .processor(processor),
                        .cacheSerializer(serializer)
                    ]
                )
                print("[EditEmployeeProfileViewModel] Firstry trajo imagen desde cache")
            } catch {
                print("[EditEmployeeProfileViewModel] Firstry no trajo imagen, error: \(error)")
            }
            do {
                if result == nil {
                    result = try await KingfisherManager.shared.retrieveImage(
                        with: imageUrl,
                        options: [
                            .cacheMemoryOnly,
                            .processor(processor),
                            .cacheSerializer(serializer)
                        ]
                    )
                }
                print("[EditEmployeeProfileViewModel] Secondtry trajo imagen desde cache")
            } catch {
                print("[EditEmployeeProfileViewModel] Secondtry no trajo imagen, error: \(error)")
                throw error
            }
            print("[EditEmployeeProfileViewModel] Se obtuvo la imagen desde Kingfisher")
            guard let result else {
                throw KingfisherError.requestError(reason: .invalidURL(request: .init(url: imageUrl)))
            }
            let optimizedImage = try self.saveImageUseCase.getOptimizedImage(uiImage: result.image)
            print("[EditEmployeeProfileViewModel] Se optimizo la imagen")
            self.selectedLocalImage = optimizedImage
            print("[EditEmployeeProfileViewModel] Se coloca la imagen a la vista")
        }
    }
    @MainActor
    func loadEmployeeProfile(employeeCic: String, dismiss: DismissAction) async {
        do {
            let employee = try await self.getEmployeesUseCase.getEmployee(employeeCic: employeeCic)
            let isOwnProfile = self.getEmployeesUseCase.isOwnProfile(employeeCic: employeeCic)
            try await self.setEmployeeField(employee: employee, isOwnProfile: isOwnProfile)
        } catch {
            print("Error: \(error.localizedDescription)")
            let alertInfo = AlertInfo(tittle: "Error", message: error.localizedDescription, mainButton: AlertInfo.ButtonConfig(text: "Aceptar", action: { [weak self] in
                dismiss()
                self?.dismissAlert()
            }))
            await showAlert(alertInfo: alertInfo)
        }
    }
    func saveSelectedImage() async throws {
        guard let selectedLocalImage else { return }
        let imageUrl = try await self.saveImageUseCase.execute(uiImage: selectedLocalImage)
        await MainActor.run {
            self.fields.imageUrl = imageUrl.absoluteString
        }
    }
    @MainActor
    func saveEmployeeProfile(employeeCic: String, dismiss: DismissAction) async {
        do {
            if self.fields.imageUrl == "" && self.selectedLocalImage != nil {
                try await self.saveSelectedImage()
            }
            let employee: Employee
            if self.fields.imageUrl.isEmpty {
                employee = self.getEmployee()
            } else {
                guard let imageUrl = URL(string: self.fields.imageUrl) else {
                    print("[EditEmployeeProfileViewModel] Los valores no se pueden convertir correctamente, url: \(self.fields.imageUrl)")
                    throw LocalStorageError.saveFailed("La imagen no fue guardada correctamente.")
                }
                employee = self.getEmployee(imageUrl: imageUrl.absoluteString)
            }
            self.isLoading = true
            try Task.checkCancellation()
            try await self.createEmployeeUseCase.execute(employee: employee)
            self.fields = .init()
            self.isLoading = false
            dismiss()
        } catch {
            print("Error: \(error.localizedDescription)")
            let alertInfo = AlertInfo(tittle: "Error", message: error.localizedDescription, mainButton: AlertInfo.ButtonConfig(text: "Aceptar", action: { [weak self] in
                self?.isLoading = false
                self?.dismissAlert()
                dismiss()
            }))
            await showAlert(alertInfo: alertInfo)
        }
    }
    private func getEmployee(imageUrl: String? = nil) -> Employee {
        let employeeCic: String
        if self.fields.employeeCic.isEmpty {
            employeeCic = UUID().uuidString
        } else {
            employeeCic = self.fields.employeeCic
        }
        return Employee(
            id: UUID(),
            employeeCic: employeeCic,//nil porque es completar registro
            name: self.fields.name,
            email: self.fields.email,
            lastName: self.fields.lastName,
            role: self.fields.role,
            imageUrl: imageUrl,
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

struct EditEmployeeProfileFields {
    var isShowingPicker = false
    var isPickerDisable: Bool = false
    var employeeCic = ""
    var imageUrl: String = ""
    var name: String = ""
    var isNameDisable: Bool = false
    var lastName: String = ""
    var isLastNameDisable: Bool = false
    var email: String = ""
    var isEmailDisable: Bool = false
    var phone: String = ""
    var isPhoneDisable: Bool = false
    var role: UserSubsidiaryRole = .employee
    var isRoleDisable: Bool = false
}
