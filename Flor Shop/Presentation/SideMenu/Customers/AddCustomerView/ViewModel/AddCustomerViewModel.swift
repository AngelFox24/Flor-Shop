import Foundation
import _PhotosUI_SwiftUI

@Observable
class AddCustomerViewModel {
    var fieldsAddCustomer: FieldsAddCustomer = FieldsAddCustomer()
    var isPresented: Bool = false
    var selectedImage: UIImage?
    var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
    
    private let saveCustomerUseCase: SaveCustomerUseCase
    private let getImageUseCase: GetImageUseCase
    
    init(
        saveCustomerUseCase: SaveCustomerUseCase,
        getImageUseCase: GetImageUseCase
    ) {
        self.saveCustomerUseCase = saveCustomerUseCase
        self.getImageUseCase = getImageUseCase
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
                let imageDataTreated = try await LocalImageManagerImpl.getEfficientImageTreated(image: uiImage)
                let uiImageTreated = try LocalImageManagerImpl.getUIImage(data: imageDataTreated)
                await MainActor.run {
                    print("Se le asigno la imagen")
                    self.selectedImage = uiImageTreated
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    func fieldsTrue() {
        print("All value true")
        fieldsAddCustomer.nameEdited = true
        fieldsAddCustomer.lastnameEdited = true
        fieldsAddCustomer.phoneNumberEdited = true
        //fieldsAddCustomer.dateLimitEdited = true
        fieldsAddCustomer.creditLimitEdited = true
    }
    func loadCustomer(id: UUID) {
        
    }
    func editCustomer(customer: Customer) async throws {
        if let imageUrl = customer.image {
            let uiImage = try await LocalImageManagerImpl.loadImage(image: imageUrl)
            await MainActor.run {
                self.selectedImage = uiImage
            }
            print("Se agrego el id correctamente")
        }
        await MainActor.run {
            fieldsAddCustomer.idImage = customer.image?.id
            fieldsAddCustomer.id = customer.id
            fieldsAddCustomer.name = customer.name
            fieldsAddCustomer.lastname = customer.lastName
            fieldsAddCustomer.phoneNumber = customer.phoneNumber
            fieldsAddCustomer.totalDebt = customer.totalDebt.cents
            fieldsAddCustomer.dateLimit = customer.dateLimit
            fieldsAddCustomer.firstDatePurchaseWithCredit = customer.firstDatePurchaseWithCredit
            fieldsAddCustomer.dateLimitFlag = customer.isDateLimitActive
            fieldsAddCustomer.creditLimitFlag = customer.isCreditLimitActive
            fieldsAddCustomer.creditDays = String(customer.creditDays)
            fieldsAddCustomer.creditScore = customer.creditScore
            fieldsAddCustomer.creditLimit = customer.creditLimit.cents
        }     }
    func addCustomer() async throws {
        await MainActor.run {
            fieldsTrue()
        }
        guard let customer = try await createCustomer() else {
            print("No se pudo crear Cliente")
            throw LocalStorageError.saveFailed("No se pudo crear Cliente")
        }
        try await self.saveCustomerUseCase.execute(customer: customer)
        await releaseResources()
    }
    func createCustomer() async throws -> Customer? {
        guard let creditDaysInt = Int(fieldsAddCustomer.creditDays) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        if isErrorsEmpty() {
            return Customer(
                id: fieldsAddCustomer.id ?? UUID(),
                customerId: fieldsAddCustomer.id ?? nil,
                name: fieldsAddCustomer.name,
                lastName: fieldsAddCustomer.lastname,
                image: try await getImageIfExist(),
                creditLimit: Money(fieldsAddCustomer.creditLimit),
                isCreditLimit: false,
                creditDays: creditDaysInt,
                isDateLimit: false,
                creditScore: fieldsAddCustomer.creditScore,
                dateLimit: fieldsAddCustomer.dateLimit,
                phoneNumber: fieldsAddCustomer.phoneNumber,
                lastDatePurchase: Date(),
                totalDebt: Money(fieldsAddCustomer.totalDebt),
                isCreditLimitActive: fieldsAddCustomer.creditLimitFlag,
                isDateLimitActive: fieldsAddCustomer.dateLimitFlag
            )
        } else {
            return nil
        }
    }
    func isErrorsEmpty() -> Bool {
        let isEmpty = self.fieldsAddCustomer.nameError.isEmpty &&
        self.fieldsAddCustomer.lastnameError.isEmpty &&
        self.fieldsAddCustomer.errorBD.isEmpty &&
        self.fieldsAddCustomer.creditDaysError.isEmpty &&
        self.fieldsAddCustomer.creditLimitError.isEmpty
        return isEmpty
    }
    func getImageIfExist() async throws -> ImageUrl? {
        guard let image = self.selectedImage else {
            return nil
        }
        return try await self.getImageUseCase.execute(uiImage: image)
    }
    func releaseResources() async {
        await MainActor.run {
            self.selectedImage = nil
            self.selectionImage = nil
            self.isPresented = false
            fieldsAddCustomer = FieldsAddCustomer()
        }
    }
}

struct FieldsAddCustomer {
    var id: UUID?
    var idImage: UUID?
    var isShowingPicker = false
    var name: String = ""
    var nameEdited: Bool = false
    var nameError: String {
        if name == "" && nameEdited {
            return "Nombre de cliente no válido"
        } else {
            return ""
        }
    }
    var lastname: String = ""
    var lastnameEdited: Bool = false
    var lastnameError: String {
        if lastname == "" && lastnameEdited {
            return "Apellido del cliente no válido"
        } else {
            return ""
        }
    }
    var phoneNumber: String = ""
    var phoneNumberEdited: Bool = false
    var totalDebt: Int = 0
    //TODO: Cambiar de Fecha a dias de Credito, luego calcular fecha
    var dateLimit: Date = Date()
    var firstDatePurchaseWithCredit: Date?
    var dateLimitString: String {
        if creditDaysError == "" {
            let calendar = Calendar.current
            if let futureDate = calendar.date(byAdding: .day, value: Int(creditDays) ?? 0, to: firstDatePurchaseWithCredit ?? Date()) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let formattedDate = dateFormatter.string(from: futureDate)
                return formattedDate
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    //var dateLimitEdited: Bool = false
    var dateLimitFlag: Bool = false
    var creditDays: String = "30"
    var creditDaysEdited: Bool = false
    var creditDaysFlag: Bool = false
    var creditDaysError: String {
        guard let creditDaysInt = Int(creditDays) else {
            return "Debe ser número entero"
        }
        if creditDaysInt <= 0 && creditDaysEdited {
            return "Debe ser mayor a 0: \(creditDaysEdited)"
        } else {
            return ""
        }
    }
    var creditScore: Int = 50
    var creditLimit: Int = 10000
    var creditLimitEdited: Bool = false
    var creditLimitFlag: Bool = false
    var creditLimitError: String {
        if creditLimit <= 0 && creditLimitEdited {
            return "Debe ser mayor a 0: \(creditLimitEdited)"
        } else {
            return ""
        }
    }
    var errorBD: String = ""
}
