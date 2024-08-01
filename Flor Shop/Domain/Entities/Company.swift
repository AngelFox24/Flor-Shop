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
