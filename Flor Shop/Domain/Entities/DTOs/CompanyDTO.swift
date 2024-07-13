//
//  ss.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/07/2024.
//

import Foundation

struct CompanyDTO: Codable {
    let id: UUID
    let companyName: String
    let ruc: String
    let createdAt: String
    let updatedAt: String
}

extension CompanyDTO {
    func toCompany() -> Company {
        return Company(
            id: id,
            companyName: companyName,
            ruc: ruc,
            createdAt: createdAt.internetDateTime() ?? minimunDate(),
            updatedAt: updatedAt.internetDateTime() ?? minimunDate()
        )
    }
}
