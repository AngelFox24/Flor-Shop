//
//  CartDetail.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 23/05/23.
//

import Foundation
import CoreData

struct CartDetail: Identifiable {
    let id: UUID
    let quantity: Int
    let subtotal: Money
    let product: Product
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
