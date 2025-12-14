import Foundation
import CoreData

struct SessionConfig: Codable, Equatable {
    let subdomain: String
    let companyCic: String
    let subsidiaryCic: String
    let employeeCic: String
    static let structName = "SessionConfig"
    
    func getCompanyEntityByCic(context: NSManagedObjectContext, companyCic: String) throws -> Tb_Company? {
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        let predicate = NSPredicate(format: "companyCic == %@", companyCic)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getSubsidiaryEntityByCic(context: NSManagedObjectContext, subsidiaryCic: String) throws -> Tb_Subsidiary? {
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "subsidiaryCic == %@ AND toCompany.companyCic == %@", subsidiaryCic, self.companyCic)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getCustomerEntityByCic(context: NSManagedObjectContext, customerCic: String) throws -> Tb_Customer? {
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate = NSPredicate(format: "customerCic == %@ AND toCompany.companyCic == %@", customerCic, self.companyCic)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getEmployeeEntityByCic(context: NSManagedObjectContext, employeeCic: String) throws -> Tb_Employee? {
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "employeeCic == %@ AND toCompany.companyCic == %@", employeeCic, self.companyCic)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getEmployeeSubsidiaryEntityByCic(context: NSManagedObjectContext, employeeCic: String) throws -> Tb_EmployeeSubsidiary? {
        let request: NSFetchRequest<Tb_EmployeeSubsidiary> = Tb_EmployeeSubsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toEmployee.employeeCic == %@ AND toSubsidiary.subsidiaryCic == %@", employeeCic, self.subsidiaryCic)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getProductEntityByCic(context: NSManagedObjectContext, productCic: String) throws -> Tb_Product? {
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "productCic == %@ AND toCompany.companyCic == %@", productCic, self.companyCic)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getProductSubsidiaryEntityByCic(context: NSManagedObjectContext, productCic: String) throws -> Tb_ProductSubsidiary? {
        let request: NSFetchRequest<Tb_ProductSubsidiary> = Tb_ProductSubsidiary.fetchRequest()
        let predicate = NSPredicate(format: "toProduct.productCic == %@ AND toSubsidiary.subsidiaryCic == %@", productCic, self.subsidiaryCic)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getCartEntityById(context: NSManagedObjectContext, cartId: UUID) throws -> Tb_Cart? {
        let filterAtt = NSPredicate(format: "idCart == %@ AND toEmployee.employeeCic == %@", cartId.uuidString, self.employeeCic)
        let request: NSFetchRequest<Tb_Cart> = Tb_Cart.fetchRequest()
        request.predicate = filterAtt
        do {
            let cartEntity = try context.fetch(request).first
            return cartEntity
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getCartDetailEntityById(context: NSManagedObjectContext, cartDetailId: UUID) throws -> Tb_CartDetail? {
        let filterAtt = NSPredicate(format: "idCartDetail == %@", cartDetailId.uuidString)
        let request: NSFetchRequest<Tb_CartDetail> = Tb_CartDetail.fetchRequest()
        request.predicate = filterAtt
        do {
            let cartDetailEntity = try context.fetch(request).first
            return cartDetailEntity
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
    func getSaleEntityById(context: NSManagedObjectContext, saleId: UUID) throws -> Tb_Sale? {
        let filterAtt = NSPredicate(format: "idSale == %@ AND toSubsidiary.subsidiaryCic == %@", saleId.uuidString, self.subsidiaryCic)
        let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
        request.predicate = filterAtt
        do {
            let saleEntity = try context.fetch(request).first
            return saleEntity
        } catch let error {
            print("Error fetching. \(error)")
            context.rollback()
            let cusError: String = "\(SessionConfig.structName) error fetching: \(error.localizedDescription)"
            throw LocalStorageError.fetchFailed(cusError)
        }
    }
}
