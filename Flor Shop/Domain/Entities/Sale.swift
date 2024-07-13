//
//  Sale.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

struct Sale: Identifiable {
    let id: UUID
    let paymentType: PaymentType
    let saleDate: Date
    let saleDetail: [SaleDetail]
    let totalSale: Money
    let createdAt: Date
    let updatedAt: Date
}

struct SaleRequest: Codable {
    let subsidiaryId: UUID
    let updatedSince: String
}

extension Sale {
    func toSaleDTO(subsidiaryId: UUID, customerId: UUID?, employeeId: UUID) -> SaleDTO {
        return SaleDTO(
            id: id,
            paymentType: paymentType.description,
            saleDate: saleDate,
            total: totalSale.cents,
            subsidiaryId: subsidiaryId,
            customerId: customerId,
            employeeId: employeeId,
            saleDetail: saleDetail.mapToListSaleDetailDTO(saleID: id),
            createdAt: createdAt.description,
            updatedAt: updatedAt.description
        )
    }
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
