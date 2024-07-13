//
//  Car.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

struct Car: Identifiable {
    let id: UUID
    let total: Int
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
