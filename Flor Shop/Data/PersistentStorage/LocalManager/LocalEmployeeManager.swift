import Foundation
import CoreData
import FlorShop_DTOs

protocol LocalEmployeeManager {
    func sync(backgroundContext: NSManagedObjectContext, employeesDTOs: [EmployeeClientDTO]) throws
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func getLastUpdated() -> Date
    func save(employee: Employee) throws
    func getEmployees() -> [Employee]
}

class LocalEmployeeManagerImpl: LocalEmployeeManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let imageService: LocalImageService
    let className = "[LocalEmployeeManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig,
        imageService: LocalImageService
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
        self.imageService = imageService
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.idSubsidiary == %@ AND syncToken != nil", self.sessionConfig.subsidiaryId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "lastToken", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let syncToken = try self.mainContext.fetch(request).compactMap{$0.syncToken}.first
            return syncToken ?? 0
        } catch let error {
            print("Error fetching. \(error)")
            return 0
        }
    }
    func getLastUpdated() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 1999, month: 1, day: 1)
        let dateFrom = calendar.date(from: components)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.idSubsidiary == %@ AND updatedAt != nil", self.sessionConfig.subsidiaryId.uuidString)
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let date = try self.mainContext.fetch(request).compactMap{$0.updatedAt}.first
            guard let dateNN = date else {
                return dateFrom!
            }
            return dateNN
        } catch let error {
            print("Error fetching. \(error)")
            return dateFrom!
        }
    }
    func sync(backgroundContext: NSManagedObjectContext, employeesDTOs: [EmployeeClientDTO]) throws {
        for employeeDTO in employeesDTOs {
            guard self.sessionConfig.subsidiaryId == employeeDTO.subsidiaryID else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): La subsidiaria no es la misma"
                throw LocalStorageError.syncFailed(cusError)
            }
            guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityById(context: backgroundContext, subsidiaryId: employeeDTO.subsidiaryID) else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): La subsidiaria no existe en la BD local"
                throw LocalStorageError.syncFailed(cusError)
            }
            if let employeeEntity = try self.sessionConfig.getEmployeeEntityById(context: backgroundContext, employeeId: employeeDTO.id) {
                guard !employeeDTO.isEquals(to: employeeEntity) else {
                    print("\(className) No se actualiza, es lo mismo")
                    continue
                }
                //Update Employee
                employeeEntity.name = employeeDTO.name
                employeeEntity.lastName = employeeDTO.lastName
                employeeEntity.active = employeeDTO.active
                employeeEntity.toImageUrl?.idImageUrl = employeeDTO.imageUrlId
                employeeEntity.email = employeeDTO.email
                employeeEntity.phoneNumber = employeeDTO.phoneNumber
                employeeEntity.role = employeeDTO.role
                employeeEntity.user = employeeDTO.user
                employeeEntity.createdAt = employeeDTO.createdAt
                employeeEntity.updatedAt = employeeDTO.updatedAt
                try saveData(context: backgroundContext)
            } else {
                //Create cart
                let cartEntity = Tb_Cart(context: backgroundContext)
                cartEntity.idCart = UUID()
                //Create Employee
                let newEmployeeEntity = Tb_Employee(context: backgroundContext)
                newEmployeeEntity.idEmployee = employeeDTO.id
                newEmployeeEntity.name = employeeDTO.name
                newEmployeeEntity.lastName = employeeDTO.lastName
                newEmployeeEntity.active = employeeDTO.active
                newEmployeeEntity.toImageUrl?.idImageUrl = employeeDTO.imageUrlId
                newEmployeeEntity.email = employeeDTO.email
                newEmployeeEntity.phoneNumber = employeeDTO.phoneNumber
                newEmployeeEntity.role = employeeDTO.role
                newEmployeeEntity.user = employeeDTO.user
                newEmployeeEntity.toSubsidiary = subsidiaryEntity
                newEmployeeEntity.toCart = cartEntity
                newEmployeeEntity.createdAt = employeeDTO.createdAt
                newEmployeeEntity.updatedAt = employeeDTO.updatedAt
                try saveData(context: backgroundContext)
            }
        }
    }
    func save(employee: Employee) throws {
        let image = try self.imageService.saveIfExist(context: self.mainContext, image: employee.image)
        if let employeeEntity = try self.sessionConfig.getEmployeeEntityById(context: self.mainContext, employeeId: employee.id) { //Busqueda por id
            employeeEntity.name = employee.name
            employeeEntity.lastName = employee.lastName
            employeeEntity.active = employee.active
            employeeEntity.email = employee.email
            employeeEntity.phoneNumber = employee.phoneNumber
            employeeEntity.role = employee.role
            employeeEntity.user = employee.user
            employeeEntity.toImageUrl = image
            employeeEntity.updatedAt = Date()
            try saveData()
        } else if employeeExist(employee: employee) { //Comprobamos si existe el mismo empleado por otros atributos
            rollback()
        } else { //Creamos un nuevo empleado
            let newEmployeeEntity = Tb_Employee(context: self.mainContext)
            newEmployeeEntity.idEmployee = employee.id
            newEmployeeEntity.email = employee.email
            newEmployeeEntity.name = employee.name
            newEmployeeEntity.lastName = employee.lastName
            newEmployeeEntity.role = employee.role
            newEmployeeEntity.active = employee.active
            newEmployeeEntity.toCart = Tb_Cart(context: self.mainContext)
            newEmployeeEntity.toSubsidiary?.idSubsidiary = self.sessionConfig.subsidiaryId
            newEmployeeEntity.toImageUrl = image
            try saveData()
        }
    }
    func getEmployees() -> [Employee] {
        let filterAtt = NSPredicate(format: "toSubsidiary.idSubsidiary == %@", self.sessionConfig.subsidiaryId.uuidString)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        request.predicate = filterAtt
        do {
            let result = try self.mainContext.fetch(request)
            return result.compactMap {$0.toEmployee()}
        } catch let error {
            print("Error fetching. \(error)")
            return []
        }
    }
    func employeeExist(employee: Employee) -> Bool {
        let filterAtt = NSPredicate(format: "(name == %@ AND lastName == %@) OR email == %@", employee.name, employee.lastName, employee.email)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        request.predicate = filterAtt
        do {
            let total = try self.mainContext.fetch(request).count
            return total == 0 ? false : true
        } catch let error {
            print("Error fetching. \(error)")
            return false
        }
    }
    //MARK: Private Funtions
    private func saveData() throws {
        do {
            try self.mainContext.save()
        } catch {
            rollback()
            let cusError: String = "\(className): \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func rollback() {
        self.mainContext.rollback()
    }
    private func saveData(context: NSManagedObjectContext) throws {
        do {
            try context.save()
        } catch {
            rollback(context: context)
            let cusError: String = "\(className) - BackgroundContext: \(error.localizedDescription)"
            throw LocalStorageError.saveFailed(cusError)
        }
    }
    private func rollback(context: NSManagedObjectContext) {
        context.rollback()
    }
}

