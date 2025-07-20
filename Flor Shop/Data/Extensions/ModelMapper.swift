//
//  ModelMapper.swift
//  Flor Shop
//
//  Created by Rodil Pampañaupa Velasque on 21/05/23.
//

import Foundation
import CoreData

extension Tb_Company {
    func toCompany() -> Company {
        return Company(
            id: idCompany ?? UUID(),
            companyId: idCompany,
            companyName: companyName ?? "",
            ruc: ruc ?? ""
        )
    }
}

extension Tb_Subsidiary {
    func toSubsidiary() -> Subsidiary {
        return Subsidiary(
            id: idSubsidiary ?? UUID(),
            subsidiaryId: idSubsidiary,
            name: name ?? "",
            image: toImageUrl?.toImage()
        )
    }
}

extension Tb_ImageUrl {
    func toImage() -> ImageUrl {
        return ImageUrl(
            id: idImageUrl ?? UUID(),
            imageUrlId: idImageUrl,
            imageUrl: imageUrl ?? "",
            imageHash: imageHash ?? ""
        )
    }
}

extension Tb_Product {
    func toProduct() -> Product {
        return Product(
            id: idProduct ?? UUID(),
            productId: idProduct,
            active: active,
            barCode: barCode,
            name: productName ?? "",
            qty: Int(quantityStock),
            unitType: unitType == nil ? UnitTypeEnum.unit : unitType == "Unit" ? UnitTypeEnum.unit : UnitTypeEnum.kilo,
            unitCost: Money(Int(unitCost)),
            unitPrice: Money(Int(unitPrice)),
            expirationDate: expirationDate ?? Date(),
            image: toImageUrl?.toImage()
        )
    }
}

extension Tb_Employee {
    func toEmployee() -> Employee {
        return Employee(
            id: idEmployee ?? UUID(),
            employeeId: idEmployee,
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
            customerId: idCustomer,
            name: name ?? "",
            lastName: lastName ?? "",
            image: toImageUrl?.toImage(),
            creditLimit: Money(Int(creditLimit)),
            isCreditLimit: isCreditLimit,
            creditDays: Int(creditDays),
            isDateLimit: isDateLimit,
            creditScore: Int(creditScore),
            dateLimit: dateLimit ?? Date(),
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            phoneNumber: phoneNumber ?? "",
            lastDatePurchase: lastDatePurchase ?? Date(),
            totalDebt: Money(Int(totalDebt)),
            isCreditLimitActive: isCreditLimitActive,
            isDateLimitActive: isDateLimitActive
        )
    }
}

extension Tb_Sale {
    func toSale() -> Sale {
        return Sale(
            id: idSale ?? UUID(),
            paymentType: PaymentType.from(description: paymentType ?? ""),
            saleDate: saleDate ?? Date(),
            //TODO: Refactor
            saleDetail: toSaleDetail?.compactMap {
                $0 as? Tb_SaleDetail
            }.mapToSaleDetailList() ?? [],
            totalSale: Money(Int(total))
        )
    }
}

extension Tb_SaleDetail {
    func toSaleDetail() -> SaleDetail {
        return SaleDetail(
            id: idSaleDetail ?? UUID(),
            image: toImageUrl?.toImage(),
            productName: productName ?? "Desconocido",
            unitType: unitType == nil ? UnitTypeEnum.unit : unitType == "Unit" ? UnitTypeEnum.unit : UnitTypeEnum.kilo,
            unitCost: Money(Int(unitCost)),
            unitPrice: Money(Int(unitPrice)),
            quantitySold: Int(quantitySold),
            paymentType: self.toSale?.paymentType == PaymentType.cash.description ? PaymentType.cash : PaymentType.loan,
            saleDate: self.toSale?.saleDate ?? Date(),
            subtotal: Money(Int(subtotal))
        )
    }
}

extension Tb_Cart {
    func toCar() -> Car {
        return Car(
            id: idCart ?? UUID(),
            cartDetails: self.toCartDetail?.compactMap {$0 as? Tb_CartDetail}.toListCartDetail() ?? []
        )
    }
}

extension Tb_CartDetail {
    func toCarDetail() -> CartDetail {
        return CartDetail(
            id: idCartDetail ?? UUID(),
            quantity: Int(quantityAdded),
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

