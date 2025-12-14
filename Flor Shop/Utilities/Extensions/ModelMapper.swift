import Foundation
import FlorShopDTOs

extension Tb_Company {
    func toCompany() throws -> Company {
        guard let companyName, let ruc else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return Company(
            id: UUID(),
            companyName: companyName,
            ruc: ruc
        )
    }
}

extension Tb_Subsidiary {
    func toSubsidiary() throws -> Subsidiary {
        guard let subsidiaryCic, let name else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return Subsidiary(
            id: UUID(),
            subsidiaryCic: subsidiaryCic,
            name: name,
            imageUrl: imageUrl
        )
    }
}

extension Tb_ProductSubsidiary {
    func toProductModel() throws -> Product {
        guard let product = toProduct,
              let productCic = product.productCic,
              let productName = product.productName,
              let unitType = product.unitType,
              let unitTypeEnum = UnitType(rawValue: unitType) else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return Product(
            id: UUID(),
            productCic: productCic,
            active: active,
            name: productName,
            qty: Int(quantityStock),
            unitType: unitTypeEnum,
            unitCost: Money(Int(unitCost)),
            unitPrice: Money(Int(unitPrice))
        )
    }
}

extension Tb_EmployeeSubsidiary {
    func toEmployeeModel() throws -> Employee {
        guard let employee = toEmployee,
              let employeeCic = employee.employeeCic,
              let name = employee.name,
              let email = employee.email,
              let role,
              let roleEnum = UserSubsidiaryRole(rawValue: role) else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return Employee(
            id: UUID(),
            employeeCic: employeeCic,
            name: name,
            email: email,
            lastName: employee.lastName,
            role: roleEnum,
            imageUrl: employee.imageUrl,
            active: active,
            phoneNumber: employee.phoneNumber
        )
    }
}

extension Tb_Customer {
    func toCustomer() throws -> Customer {
        guard let customerCic,
              let name else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return Customer(
            id: UUID(),
            customerCic: customerCic,
            name: name,
            lastName: lastName,
            imageUrl: imageUrl,
            creditLimit: Money(Int(creditLimit)),
            creditDays: Int(creditDays),
            creditScore: Int(creditScore),
            dateLimit: dateLimit,
            firstDatePurchaseWithCredit: firstDatePurchaseWithCredit,
            phoneNumber: phoneNumber,
            lastDatePurchase: lastDatePurchase ?? Date(),
            totalDebt: Money(Int(totalDebt)),
            isCreditLimitActive: isCreditLimitActive,
            isDateLimitActive: isDateLimitActive
        )
    }
}

extension Tb_Sale {
    static var schema: String = "Tb_Sale"
    func toSale() throws -> Sale {
        guard let paymentType = paymentType,
              let paymentTypeEnum = PaymentType(rawValue: paymentType),
              let saleDate
        else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return Sale(
            id: idSale!,
            paymentType: paymentTypeEnum,
            saleDate: saleDate,
            //TODO: Refactor
            saleDetail: toSaleDetail?.compactMap {
                $0 as? Tb_SaleDetail
            }.mapToSaleDetailList() ?? [],
            totalSale: Money(Int(total))
        )
    }
}

extension Tb_SaleDetail {
    func toSaleDetail() throws -> SaleDetail {
        guard let productName,
              let unitType,
              let unitTypeEnum = UnitType(rawValue: unitType),
              let paymentType = toSale?.paymentType,
              let paymentTypeEnum = PaymentType(rawValue: paymentType),
              let saleDate = toSale?.saleDate
        else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return SaleDetail(
            id: idSaleDetail ?? UUID(),
            imageUrl: imageUrl,
            productName: productName,
            unitType: unitTypeEnum,
            unitCost: Money(Int(unitCost)),
            unitPrice: Money(Int(unitPrice)),
            quantitySold: Int(quantitySold),
            paymentType: paymentTypeEnum,
            saleDate: saleDate,
            subtotal: Money(Int(subtotal))
        )
    }
}

extension Tb_Cart {
    func toCar() throws -> Car {
        guard let idCart else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return Car(
            id: idCart,
            cartDetails: self.toCartDetail?.compactMap {$0 as? Tb_CartDetail}.toListCartDetail() ?? []
        )
    }
}

extension Tb_CartDetail {
    func toCarDetail() throws -> CartDetail {
        guard let idCartDetail,
              let product = try toProductSubsidiary?.toProductModel() else {
            throw NSError(domain: "MapperError", code: 0, userInfo: nil)
        }
        return CartDetail(
            id: idCartDetail,
            quantity: Int(quantityAdded),
            product: product
        )
    }
}

// MARK: Array Extensions
extension Array where Element == Tb_ProductSubsidiary {
    func mapToListProduct() -> [Product] {
        return self.compactMap { try? $0.toProductModel() }
    }
}

extension Array where Element == Tb_SaleDetail {
    func mapToSaleDetailList() -> [SaleDetail] {
        return self.compactMap { try? $0.toSaleDetail() }
    }
}

extension Array where Element == Tb_CartDetail {
    func toListCartDetail() -> [CartDetail] {
        return self.compactMap { try? $0.toCarDetail() }
    }
}

extension Array where Element == Tb_Sale {
    func mapToListSale() -> [Sale] {
        return self.compactMap { try? $0.toSale() }
    }
}
