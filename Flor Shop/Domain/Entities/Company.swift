//
//  Company.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

struct Company: Identifiable {
    var id: UUID
    var companyName: String
    var ruc: String
    let createdAt: Date
    let updatedAt: Date
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
    func toCompanyDTO() -> CompanyDTO {
        return CompanyDTO(
            id: id,
            companyName: companyName,
            ruc: ruc,
            createdAt: createdAt.description,
            updatedAt: updatedAt.description
        )
    }
}
