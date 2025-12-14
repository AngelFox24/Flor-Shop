import Foundation
import CoreData
import FlorShopDTOs

protocol LocalEmployeeManager {
    func sync(backgroundContext: NSManagedObjectContext, employeesDTOs: [EmployeeClientDTO]) throws
    func getLastToken(context: NSManagedObjectContext) -> Int64
    func save(employee: Employee) throws
    func getEmployees() -> [Employee]
}

class LocalEmployeeManagerImpl: LocalEmployeeManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "[LocalEmployeeManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken(context: NSManagedObjectContext) -> Int64 {
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "toCompany.companyCic == %@ AND syncToken != nil", self.sessionConfig.companyCic)
        let sortDescriptor = NSSortDescriptor(key: "syncToken", ascending: false)
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
    func sync(backgroundContext: NSManagedObjectContext, employeesDTOs: [EmployeeClientDTO]) throws {
        for employeeDTO in employeesDTOs {
            guard self.sessionConfig.companyCic == employeeDTO.companyCic else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): La subsidiaria no es la misma"
                throw LocalStorageError.syncFailed(cusError)
            }
            if let employeeEntity = try self.sessionConfig.getEmployeeEntityByCic(context: backgroundContext, employeeCic: employeeDTO.employeeCic) {
                guard !employeeDTO.isEquals(to: employeeEntity) else {
                    print("\(className) No se actualiza, es lo mismo")
                    continue
                }
                //Update Employee
                employeeEntity.name = employeeDTO.name
                employeeEntity.lastName = employeeDTO.lastName
                employeeEntity.imageUrl = employeeDTO.imageUrl
                employeeEntity.email = employeeDTO.email
                employeeEntity.phoneNumber = employeeDTO.phoneNumber
                employeeEntity.syncToken = employeeDTO.syncToken
                employeeEntity.createdAt = employeeDTO.createdAt
                employeeEntity.updatedAt = employeeDTO.updatedAt
                try saveData(context: backgroundContext)
            } else {
                guard let companyEntity = try self.sessionConfig.getCompanyEntityByCic(context: backgroundContext, companyCic: employeeDTO.companyCic) else {
                    rollback(context: backgroundContext)
                    let cusError: String = "\(className): La subsidiaria no existe en la BD local"
                    throw LocalStorageError.syncFailed(cusError)
                }
                //Create Employee
                let newEmployeeEntity = Tb_Employee(context: backgroundContext)
                newEmployeeEntity.employeeCic = UUID().uuidString
                newEmployeeEntity.name = employeeDTO.name
                newEmployeeEntity.lastName = employeeDTO.lastName
                newEmployeeEntity.imageUrl = employeeDTO.imageUrl
                newEmployeeEntity.email = employeeDTO.email
                newEmployeeEntity.phoneNumber = employeeDTO.phoneNumber
                newEmployeeEntity.toCompany = companyEntity
                newEmployeeEntity.syncToken = employeeDTO.syncToken
                newEmployeeEntity.createdAt = employeeDTO.createdAt
                newEmployeeEntity.updatedAt = employeeDTO.updatedAt
                try saveData(context: backgroundContext)
            }
        }
    }
    func save(employee: Employee) throws {
        if let employeeCic = employee.employeeCic,
           let employeeSubsidiaryEntity = try self.sessionConfig.getEmployeeSubsidiaryEntityByCic(
            context: self.mainContext,
            employeeCic: employeeCic
           ) {
            guard let employeeEntity = employeeSubsidiaryEntity.toEmployee else {
                rollback(context: self.mainContext)
                let cusError: String = "\(className): El empleado no existe para esta sucursal."
                throw LocalStorageError.entityNotFound(cusError)
            }
            employeeEntity.name = employee.name
            employeeEntity.lastName = employee.lastName
            employeeEntity.email = employee.email
            employeeEntity.phoneNumber = employee.phoneNumber
            employeeEntity.imageUrl = employee.imageUrl
            employeeEntity.updatedAt = Date()
            employeeSubsidiaryEntity.active = employee.active
            employeeSubsidiaryEntity.role = employee.role.rawValue
            try saveData()
        } else if employeeExist(employee: employee) { //Comprobamos si existe el mismo empleado por otros atributos
            rollback()
        } else { //Creamos un nuevo empleado
            guard let companyEntity = try self.sessionConfig.getCompanyEntityByCic(context: self.mainContext, companyCic: self.sessionConfig.companyCic) else {
                rollback(context: self.mainContext)
                let cusError: String = "\(className): La compañia no existe en la BD local"
                throw LocalStorageError.entityNotFound(cusError)
            }
            guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
                context: self.mainContext,
                subsidiaryCic: self.sessionConfig.subsidiaryCic
            ) else {
                rollback(context: self.mainContext)
                let cusError: String = "\(className): La subsidiaria no existe en la BD local"
                throw LocalStorageError.syncFailed(cusError)
            }
            let newEmployeeEntity = Tb_Employee(context: self.mainContext)
            newEmployeeEntity.employeeCic = UUID().uuidString
            newEmployeeEntity.email = employee.email
            newEmployeeEntity.name = employee.name
            newEmployeeEntity.lastName = employee.lastName
            newEmployeeEntity.toCompany = companyEntity
            newEmployeeEntity.imageUrl = employee.imageUrl
            newEmployeeEntity.createdAt = Date()
            newEmployeeEntity.updatedAt = Date()
            let newEmployeeSubsidiaryEntity = Tb_EmployeeSubsidiary(context: self.mainContext)
            newEmployeeSubsidiaryEntity.active = employee.active
            newEmployeeSubsidiaryEntity.role = employee.role.rawValue
            newEmployeeSubsidiaryEntity.toEmployee = newEmployeeEntity
            newEmployeeSubsidiaryEntity.toSubsidiary = subsidiaryEntity
            try saveData()
        }
    }
    func getEmployees() -> [Employee] {
        let filterAtt = NSPredicate(format: "toEmployee.toSubsidiary.subsidiaryCic == %@", self.sessionConfig.subsidiaryCic)
        let request: NSFetchRequest<Tb_EmployeeSubsidiary> = Tb_EmployeeSubsidiary.fetchRequest()
        request.predicate = filterAtt
        do {
            let result = try self.mainContext.fetch(request)
            return result.compactMap { try? $0.toEmployeeModel() }
        } catch let error {
            print("Error fetching. \(error)")
            return []
        }
    }
    func employeeExist(employee: Employee) -> Bool {
        let filterAtt: NSPredicate
        if let lastName = employee.lastName {
            filterAtt = NSPredicate(format: "(name == %@ AND lastName == %@) OR email == %@", employee.name, lastName, employee.email)
        } else {
            filterAtt = NSPredicate(format: "(name == %@) OR email == %@", employee.name, employee.email)
        }
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
    func ss(sa: inout Int) {
        
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

