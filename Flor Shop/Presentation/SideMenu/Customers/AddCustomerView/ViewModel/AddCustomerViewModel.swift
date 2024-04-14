//
//  AddCusterViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/10/23.
//

import Foundation
import _PhotosUI_SwiftUI

class AddCustomerViewModel: ObservableObject {
    @Published var fieldsAddCustomer: FieldsAddCustomer = FieldsAddCustomer()
    @Published var isLoading: Bool = false
    @Published var isPresented: Bool = false
    @Published var selectedImage: UIImage?
    @Published var selectionImage: PhotosPickerItem? = nil {
        didSet{
            setImage(from: selectionImage)
        }
    }
    let saveCustomerUseCase: SaveCustomerUseCase
    let loadSavedImageUseCase: LoadSavedImageUseCase
    let saveImageUseCase: SaveImageUseCase
    
    init(saveCustomerUseCase: SaveCustomerUseCase, loadSavedImageUseCase: LoadSavedImageUseCase, saveImageUseCase: SaveImageUseCase) {
        self.saveCustomerUseCase = saveCustomerUseCase
        self.loadSavedImageUseCase = loadSavedImageUseCase
        self.saveImageUseCase = saveImageUseCase
    }
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        self.isLoading = true
        Task {
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    print("Imagen vacia")
                    return
                }
                //selectedImage = uiImage
                //TODO: Save image with id
                await MainActor.run {
                    isPresented = false
                    selectedImage = uiImage
                }
            } catch {
                print("Error: \(error)")
            }
        }
        self.isLoading = false
    }
    func fieldsTrue() {
        print("All value true")
        fieldsAddCustomer.nameEdited = true
        fieldsAddCustomer.lastnameEdited = true
        fieldsAddCustomer.phoneNumberEdited = true
        //fieldsAddCustomer.dateLimitEdited = true
        fieldsAddCustomer.creditLimitEdited = true
    }
    func editCustomer(customer: Customer) {
        if let imageId = customer.image?.id {
            self.selectedImage = self.loadSavedImageUseCase.execute(id: imageId)
            fieldsAddCustomer.idImage = imageId
            print("Se agrego el id correctamente")
        }
        fieldsAddCustomer.id = customer.id
        fieldsAddCustomer.name = customer.name
        fieldsAddCustomer.lastname = customer.lastName
        fieldsAddCustomer.phoneNumber = customer.phoneNumber
        fieldsAddCustomer.totalDebt = String(customer.totalDebt)
        fieldsAddCustomer.dateLimit = customer.dateLimit
        fieldsAddCustomer.firstDatePurchaseWithCredit = customer.firstDatePurchaseWithCredit
        fieldsAddCustomer.dateLimitFlag = customer.isDateLimitActive
        fieldsAddCustomer.creditLimitFlag = customer.isCreditLimitActive
        fieldsAddCustomer.creditDays = String(customer.creditDays)
        fieldsAddCustomer.creditScore = customer.creditScore
        fieldsAddCustomer.creditLimit = String(customer.creditLimit)
        
    }
    func addCustomer() async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        guard let customer = createCustomer() else {
            print("No se pudo crear Cliente")
            return false
        }
        let result = self.saveCustomerUseCase.execute(customer: customer)
        if result == "" {
            print("Se añadio correctamente")
            await releaseResources()
            return true
        } else {
            print(result)
            await MainActor.run {
                fieldsAddCustomer.errorBD = result
            }
            return false
        }
    }
    func createCustomer() -> Customer? {
        guard let totalDebt = Double(fieldsAddCustomer.totalDebt) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        guard let creditLimitDouble = Double(fieldsAddCustomer.creditLimit) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        guard let creditDaysInt = Int(fieldsAddCustomer.creditDays) else {
            print("Los valores no se pueden convertir correctamente")
            return nil
        }
        return Customer(id: fieldsAddCustomer.id ?? UUID(), name: fieldsAddCustomer.name, lastName: fieldsAddCustomer.lastname, image: saveSelectedImage(), creditLimit: creditLimitDouble, isCreditLimit: false, creditDays: creditDaysInt, isDateLimit: false, creditScore: fieldsAddCustomer.creditScore, dateLimit: fieldsAddCustomer.dateLimit, phoneNumber: fieldsAddCustomer.phoneNumber, totalDebt: totalDebt, isCreditLimitActive: fieldsAddCustomer.creditLimitFlag, isDateLimitActive: fieldsAddCustomer.dateLimitFlag)
    }
    func saveSelectedImage() -> ImageUrl? {
        guard let image = self.selectedImage else {
            return nil
        }
        guard let idImage = fieldsAddCustomer.idImage else {
            print("Se crea nuevo id")
            let newIdImage = UUID()
            let imageHash = self.saveImageUseCase.execute(id: newIdImage, image: image, resize: true)
            return ImageUrl(id: newIdImage, imageUrl: "", imageHash: imageHash)
        }
        print("Se usa el mismo id")
        let imageHash = self.saveImageUseCase.execute(id: idImage, image: image, resize: true)
        return ImageUrl(id: idImage, imageUrl: "", imageHash: imageHash)
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

class FieldsAddCustomer {
    var id: UUID?
    var idImage: UUID?
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
    var totalDebt: String = "0"
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
    var creditLimit: String = "100"
    var creditLimitEdited: Bool = false
    var creditLimitFlag: Bool = false
    var creditLimitError: String {
        guard let creditLimitDouble = Double(creditLimit) else {
            return "Debe ser número decimal o entero"
        }
        if creditLimitDouble <= 0 && creditLimitEdited {
            return "Debe ser mayor a 0: \(creditLimitEdited)"
        } else {
            return ""
        }
    }
    var errorBD: String = ""
}
