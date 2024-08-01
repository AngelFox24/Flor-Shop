//
//  SessionConfig.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 15/07/2024.
//

import Foundation
import CoreData

struct SessionConfig: Codable {
    let companyId: UUID
    let subsidiaryId: UUID
    let employeeId: UUID
    
    func getCompanyEntityById(context: NSManagedObjectContext, companyId: UUID) -> Tb_Company? {
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        let predicate = NSPredicate(format: "idCompany == %@", companyId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getSubsidiaryEntityById(context: NSManagedObjectContext, subsidiaryId: UUID) -> Tb_Subsidiary? {
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        let predicate = NSPredicate(format: "idSubsidiary == %@ AND toCompany.idCompany == %@", subsidiaryId.uuidString, self.companyId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getCustomerEntityById(context: NSManagedObjectContext, customerId: UUID) -> Tb_Customer? {
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        let predicate = NSPredicate(format: "idCustomer == %@ AND toCompany.idCompany == %@", customerId.uuidString, self.companyId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getEmployeeEntityById(context: NSManagedObjectContext, employeeId: UUID) -> Tb_Employee? {
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        let predicate = NSPredicate(format: "idEmployee == %@ AND toSubsidiary.idSubsidiary == %@", employeeId.uuidString, self.subsidiaryId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getProductEntityById(context: NSManagedObjectContext, productId: UUID) -> Tb_Product? {
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        let predicate = NSPredicate(format: "idProduct == %@ AND toSubsidiary.idSubsidiary == %@", productId.uuidString, self.subsidiaryId.uuidString)
        request.predicate = predicate
        request.fetchLimit = 1
        do {
            let result = try context.fetch(request).first
            return result
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getCartEntityById(context: NSManagedObjectContext, cartId: UUID) -> Tb_Cart? {
        let filterAtt = NSPredicate(format: "idCart == %@ AND toEmployee.idEmployee == %@", cartId.uuidString, self.employeeId.uuidString)
        let request: NSFetchRequest<Tb_Cart> = Tb_Cart.fetchRequest()
        request.predicate = filterAtt
        do {
            let cartEntity = try context.fetch(request).first
            return cartEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getCartDetailEntityById(context: NSManagedObjectContext, cartDetailId: UUID) -> Tb_CartDetail? {
        let filterAtt = NSPredicate(format: "idCartDetail == %@", cartDetailId.uuidString)
        let request: NSFetchRequest<Tb_CartDetail> = Tb_CartDetail.fetchRequest()
        request.predicate = filterAtt
        do {
            let cartDetailEntity = try context.fetch(request).first
            return cartDetailEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getSaleEntityById(context: NSManagedObjectContext, saleId: UUID) -> Tb_Sale? {
        let filterAtt = NSPredicate(format: "idSale == %@ AND toSubsidiary.idSubsidiary == %@", saleId.uuidString, self.subsidiaryId.uuidString)
        let request: NSFetchRequest<Tb_Sale> = Tb_Sale.fetchRequest()
        request.predicate = filterAtt
        do {
            let saleEntity = try context.fetch(request).first
            return saleEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
    func getImageEntityById(context: NSManagedObjectContext, imageId: UUID) -> Tb_ImageUrl? {
        let filterAtt = NSPredicate(format: "idImageUrl == %@", imageId.uuidString)
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        request.predicate = filterAtt
        do {
            let imageEntity = try context.fetch(request).first
            return imageEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}
