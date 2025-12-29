import Foundation
import CoreData
import FlorShopDTOs

protocol LocalEmployeeSubsidiaryManager {
    func getLastToken() -> Int64
    func sync(backgroundContext: NSManagedObjectContext, employeesSubsidiaryDTOs: [EmployeeSubsidiaryClientDTO]) throws
}

class LocalEmployeeSubsidiaryManagerImpl: LocalEmployeeSubsidiaryManager {
    let sessionConfig: SessionConfig
    let mainContext: NSManagedObjectContext
    let className = "[LocalEmployeeSubsidiaryManager]"
    init(
        mainContext: NSManagedObjectContext,
        sessionConfig: SessionConfig
    ) {
        self.mainContext = mainContext
        self.sessionConfig = sessionConfig
    }
    func getLastToken() -> Int64 {
        let request: NSFetchRequest<Tb_EmployeeSubsidiary> = Tb_EmployeeSubsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toSubsidiary.subsidiaryCic == %@ AND syncToken != nil", self.sessionConfig.subsidiaryCic)
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
    func sync(backgroundContext: NSManagedObjectContext, employeesSubsidiaryDTOs: [EmployeeSubsidiaryClientDTO]) throws {
        for employeeSubsidiaryDTO in employeesSubsidiaryDTOs {
            guard self.sessionConfig.subsidiaryCic == employeeSubsidiaryDTO.subsidiaryCic else {
                rollback(context: backgroundContext)
                let cusError: String = "\(className): La subsidiaria no es la misma"
                throw LocalStorageError.syncFailed(cusError)
            }
            if let employeeSubsidiaryEntity = try self.sessionConfig.getEmployeeSubsidiaryEntityByCic(
                context: backgroundContext,
                employeeCic: employeeSubsidiaryDTO.employeeCic
            ) {
                guard !employeeSubsidiaryDTO.isEquals(to: employeeSubsidiaryEntity) else {
                    print("\(className) No se actualiza, es lo mismo")
                    continue
                }
                //Update Employee
                employeeSubsidiaryEntity.active = employeeSubsidiaryDTO.active
                employeeSubsidiaryEntity.role = employeeSubsidiaryDTO.role.rawValue
                employeeSubsidiaryEntity.syncToken = employeeSubsidiaryDTO.syncToken
                employeeSubsidiaryEntity.createdAt = employeeSubsidiaryDTO.createdAt
                employeeSubsidiaryEntity.updatedAt = employeeSubsidiaryDTO.updatedAt
                try saveData(context: backgroundContext)
                print("\(className) Se creo el empleadoSubsidiary")
            } else {
                guard let employeeEntity = try self.sessionConfig.getEmployeeEntityByCic(
                    context: backgroundContext,
                    employeeCic: employeeSubsidiaryDTO.employeeCic
                ) else {
                    rollback(context: backgroundContext)
                    let cusError: String = "\(className): El empleado no existe en la BD local"
                    throw LocalStorageError.syncFailed(cusError)
                }
                guard let subsidiaryEntity = try self.sessionConfig.getSubsidiaryEntityByCic(
                    context: backgroundContext,
                    subsidiaryCic: employeeSubsidiaryDTO.subsidiaryCic
                ) else {
                    rollback(context: backgroundContext)
                    let cusError: String = "\(className): La subsidiaria no existe en la BD local"
                    throw LocalStorageError.syncFailed(cusError)
                }
                //Create Employee
                let newEmployeeSubsidiaryEntity = Tb_EmployeeSubsidiary(context: backgroundContext)
                newEmployeeSubsidiaryEntity.active = employeeSubsidiaryDTO.active
                newEmployeeSubsidiaryEntity.role = employeeSubsidiaryDTO.role.rawValue
                newEmployeeSubsidiaryEntity.syncToken = employeeSubsidiaryDTO.syncToken
                newEmployeeSubsidiaryEntity.createdAt = employeeSubsidiaryDTO.createdAt
                newEmployeeSubsidiaryEntity.updatedAt = employeeSubsidiaryDTO.updatedAt
                newEmployeeSubsidiaryEntity.toEmployee = employeeEntity
                newEmployeeSubsidiaryEntity.toSubsidiary = subsidiaryEntity
                try saveData(context: backgroundContext)
                print("\(className) Se actualizo el empleadoSubsidiary")
            }
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

