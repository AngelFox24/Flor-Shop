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

extension ImageUrl {
    func toImageUrlEntity(context: NSManagedObjectContext) -> Tb_ImageUrl? {
        let filterAtt = NSPredicate(format: "imageUrl == %@", imageUrl)
        let request: NSFetchRequest<Tb_ImageUrl> = Tb_ImageUrl.fetchRequest()
        request.predicate = filterAtt
        do {
            let imageUrlEntity = try context.fetch(request).first
            if let image = imageUrlEntity {
                return image
            } else {
                let newImage = Tb_ImageUrl(context: context)
                newImage.idImageUrl = id
                newImage.imageUrl = imageUrl
                return newImage
            }
        } catch let error {
            print("Error fetching. \(error)")
            return nil
        }
    }
}

extension Tb_Company {
    func toCompany() -> Company {
        return Company(id: idCompany ?? UUID(),
                       companyName: companyName ?? "",
                       ruc: ruc ?? "")
    }
}

extension Tb_Subsidiary {
    func toSubsidiary() -> Subsidiary {
        return Subsidiary(id: idSubsidiary ?? UUID(),
                          name: name ?? "",
                          image: ImageUrl(id: toImageUrl?.idImageUrl ?? UUID(),
                                          imageUrl: toImageUrl?.imageUrl ?? ImageUrl.getDummyImage().imageUrl))
    }
}

extension Tb_Product {
    func toProduct() -> Product {
        return Product(id: idProduct ?? UUID(),
                       name: productName ?? "",
                       qty: Int(quantityStock),
                       unitCost: unitCost,
                       unitPrice: unitPrice,
                       expirationDate: expirationDate ?? Date(),
                       image: ImageUrl(id: toImageUrl?.idImageUrl ?? UUID(),
                                       imageUrl: toImageUrl?.imageUrl ?? ImageUrl.getDummyImage().imageUrl))
    }
}

extension Tb_Employee {
    func toEmployee() -> Employee {
        return Employee(id: idEmployee ?? UUID(),
                        name: name ?? "",
                        user: user ?? "",
                        email: email ?? "",
                        lastName: lastName ?? "",
                        role: role ?? "",
                        image: ImageUrl(id: toImageUrl?.idImageUrl ?? UUID(),
                                        imageUrl: toImageUrl?.imageUrl ?? ImageUrl.getDummyImage().imageUrl),
                        active: active)
    }
}

extension Tb_Sale {
    func toSale() -> Sale {
        return Sale(id: idSale ?? UUID(),
                    saleDate: saleDate ?? Date(),
                    totalSale: total)
    }
}

extension Tb_Cart {
    func mapToCar() -> Car {
        return Car(id: idCart ?? UUID(),
                   total: total)
    }
}

extension Tb_CartDetail {
    func mapToCarDetail() -> CartDetail {
        return CartDetail(
            id: idCartDetail ?? UUID(),
            quantity: Int(quantityAdded),
            subtotal: subtotal,
            product: toProduct?.toProduct() ?? Product.getDummyProduct())
    }
}

// MARK: Array Extensions
extension Array where Element == Tb_Product {
    func mapToListProduct() -> [Product] {
        return self.map {$0.toProduct()}
    }
}

extension Array where Element == Product {
    func mapToListProductEntity(context: NSManagedObjectContext) -> [Tb_Product] {
        return self.compactMap {$0.toProductEntity(context: context)}
    }
}

extension Array where Element == Tb_CartDetail {
    func mapToListCartDetail() -> [CartDetail] {
        return self.map {$0.mapToCarDetail()}
    }
}

extension Array where Element == Tb_Sale {
    func mapToListSale() -> [Sale] {
        return self.map {$0.toSale()}
    }
}

