//
//  ModelMapper.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

extension Product {
    func toProductEntity(context: NSManagedObjectContext) -> Tb_Product? {
        let filterAtt = NSPredicate(format: "idProduct == %@", id.uuidString)
        let request: NSFetchRequest<Tb_Product> = Tb_Product.fetchRequest()
        request.predicate = filterAtt
        do {
            let productEntity = try context.fetch(request).first
            return productEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

extension Employee {
    func toEmployeeEntity(context: NSManagedObjectContext) -> Tb_Employee? {
        let filterAtt = NSPredicate(format: "idEmployee == %@", id.uuidString)
        let request: NSFetchRequest<Tb_Employee> = Tb_Employee.fetchRequest()
        request.predicate = filterAtt
        do {
            let employeeEntity = try context.fetch(request).first
            return employeeEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

extension Car {
    func toCartEntity(context: NSManagedObjectContext) -> Tb_Cart? {
        let filterAtt = NSPredicate(format: "idCart == %@", id.uuidString)
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
}

extension Subsidiary {
    func toSubsidiaryEntity(context: NSManagedObjectContext) -> Tb_Subsidiary? {
        let filterAtt = NSPredicate(format: "idSubsidiary == %@", id.uuidString)
        let request: NSFetchRequest<Tb_Subsidiary> = Tb_Subsidiary.fetchRequest()
        request.predicate = filterAtt
        do {
            let subsidiaryEntity = try context.fetch(request).first
            return subsidiaryEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

extension CartDetail {
    func toCartDetailEntity(context: NSManagedObjectContext) -> Tb_CartDetail? {
        let filterAtt = NSPredicate(format: "idCartDetail == %@", id.uuidString)
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
}

extension Company {
    func toCompanyEntity(context: NSManagedObjectContext) -> Tb_Company? {
        let filterAtt = NSPredicate(format: "idCompany == %@", id.uuidString)
        let request: NSFetchRequest<Tb_Company> = Tb_Company.fetchRequest()
        request.predicate = filterAtt
        do {
            let companyEntity = try context.fetch(request).first
            return companyEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

extension Customer {
    func toCustomerEntity(context: NSManagedObjectContext) -> Tb_Customer? {
        let filterAtt = NSPredicate(format: "idCustomer == %@", id.uuidString)
        let request: NSFetchRequest<Tb_Customer> = Tb_Customer.fetchRequest()
        request.predicate = filterAtt
        do {
            let customerEntity = try context.fetch(request).first
            return customerEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

extension Sale {
    func toSaleEntity(context: NSManagedObjectContext) -> Tb_Sale? {
        let filterAtt = NSPredicate(format: "idSale == %@", id.uuidString)
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
}

extension ImageUrl {
    func toImageUrlEntity(context: NSManagedObjectContext) -> Tb_ImageUrl? {
        let filterAtt = NSPredicate(format: "(imageUrl == %@ AND imageUrl != '' AND imageUrl != nil) OR (imageHash == %@ AND imageHash != '' AND imageHash != nil)", imageUrl, imageHash)
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        request.predicate = filterAtt
        do {
            let imageUrlEntity = try context.fetch(request).first
            print("CoreData Extract Id: \(String(describing: imageUrlEntity?.idImageUrl?.uuidString)) Hash: \(String(describing: imageUrlEntity?.imageHash))")
            return imageUrlEntity
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

extension Tb_Company {
    func toCompany() -> Company {
        return Company(
            id: idCompany ?? UUID(),
            companyName: companyName ?? "",
            ruc: ruc ?? ""
        )
    }
}

extension Tb_Subsidiary {
    func toSubsidiary() -> Subsidiary {
        return Subsidiary(
            id: idSubsidiary ?? UUID(),
            name: name ?? "",
            image: toImageUrl?.toImage()
        )
    }
}

extension Tb_ImageUrl {
    func toImage() -> ImageUrl {
        return ImageUrl(
            id: idImageUrl ?? UUID(),
            imageUrl: imageUrl ?? "",
            imageHash: imageHash ?? ""
        )
    }
}

extension Tb_Product {
    func toProduct() -> Product {
        return Product(
            id: idProduct ?? UUID(),
            active: active,
            barCode: barCode,
            name: productName ?? "",
            qty: Int(quantityStock),
            unitType: unitType == nil ? UnitTypeEnum.unit : unitType == "Unit" ? UnitTypeEnum.unit : UnitTypeEnum.kilo,
            unitCost: Money(cents: Int(unitCost)),
            unitPrice: Money(cents: Int(unitPrice)),
            expirationDate: expirationDate ?? Date(),
            image: toImageUrl?.toImage()
        )
    }
}

extension Tb_Employee {
    func toEmployee() -> Employee {
        return Employee(
            id: idEmployee ?? UUID(),
            name: name ?? "",
            user: user ?? "",
            email: email ?? "",
            lastName: lastName ?? "",
            role: role ?? "",
            image: toImageUrl?.toImage(),
            active: active,
            phoneNumber: phoneNumber ?? ""
        )
    }
}

extension Tb_Customer {
    func toCustomer() -> Customer {
        return Customer(
            id: idCustomer ?? UUID(),
            name: name ?? "",
            lastName: lastName ?? "",
            image: toImageUrl?.toImage(),
            creditLimit: Money(cents: Int(creditLimit)),
            isCreditLimit: isCreditLimit,
            creditDays: Int(creditDays),
            isDateLimit: isDateLimit,
            creditScore: Int(creditScore),
            dateLimit: dateLimit ?? Date(),
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            phoneNumber: phoneNumber ?? "",
            totalDebt: Money(cents: Int(totalDebt)),
            isCreditLimitActive: isCreditLimitActive,
            isDateLimitActive: isDateLimitActive
        )
    }
}

extension Tb_Sale {
    func toSale() -> Sale {
        return Sale(id: idSale ?? UUID(),
                    saleDate: saleDate ?? Date(),
                    //TODO: Refactor
                    saleDetail: toSaleDetail?.compactMap {$0 as? Tb_SaleDetail}.mapToSaleDetailList() ?? [],
                    totalSale: Money(cents: Int(total)))
    }
}

extension Tb_SaleDetail {
    func toSaleDetail() -> SaleDetail {
        return SaleDetail(
            id: idSaleDetail ?? UUID(),
            image: toImageUrl?.toImage(),
            productName: productName ?? "Desconocido",
            unitType: unitType == nil ? UnitTypeEnum.unit : unitType == "Unit" ? UnitTypeEnum.unit : UnitTypeEnum.kilo,
            unitCost: Money(cents: Int(unitCost)),
            unitPrice: Money(cents: Int(unitPrice)),
            quantitySold: Int(quantitySold),
            paymentType: self.toSale?.paymentType == PaymentType.cash.description ? PaymentType.cash : PaymentType.loan,
            saleDate: self.toSale?.saleDate ?? Date(),
            subtotal: Money(cents: Int(subtotal))
        )
    }
}

extension Tb_Cart {
    func toCar() -> Car {
        return Car(
            id: idCart ?? UUID(),
            total: Int(total)
        )
    }
}

extension Tb_CartDetail {
    func toCarDetail() -> CartDetail {
        return CartDetail(
            id: idCartDetail ?? UUID(),
            quantity: Int(quantityAdded),
            subtotal: Money(cents: Int(subtotal)),
            product: toProduct?.toProduct() ?? Product.getDummyProduct()
        )
    }
}

// MARK: Array Extensions
extension Array where Element == Tb_Product {
    func mapToListProduct() -> [Product] {
        return self.map {$0.toProduct()}
    }
}

extension Array where Element == Tb_SaleDetail {
    func mapToSaleDetailList() -> [SaleDetail] {
        return self.map {$0.toSaleDetail()}
    }
}

extension Array where Element == Product {
    func mapToListProductEntity(context: NSManagedObjectContext) -> [Tb_Product] {
        return self.compactMap {$0.toProductEntity(context: context)}
    }
}

extension Array where Element == Tb_CartDetail {
    func toListCartDetail() -> [CartDetail] {
        return self.map {$0.toCarDetail()}
    }
}

extension Array where Element == Tb_Sale {
    func mapToListSale() -> [Sale] {
        return self.map {$0.toSale()}
    }
}

