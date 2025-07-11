//
//  Request Parameters.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 05/10/2024.
//
import Foundation
//MARK: ServerErrorResponse
struct ServerErrorResponse: Decodable {
    let error: Bool
    let reason: String
}
//MARK: Session Parameters
struct LogInParameters: Encodable {
    let username: String
    let password: String
}
struct RegisterParameters: Encodable {
    let company: CompanyDTO
    let subsidiaryImage: ImageURLDTO?
    let subsidiary: SubsidiaryDTO
    let employeeImage: ImageURLDTO?
    let employee: EmployeeDTO
    
    init?(registerStuff: RegisterStuffs) {
        self.company = registerStuff.company.toCompanyDTO()
        self.subsidiaryImage = registerStuff.subsidiary.image?.toImageUrlDTO(imageData: nil)
        self.subsidiary = registerStuff.subsidiary.toSubsidiaryDTO(companyId: self.company.id)
        self.employeeImage = registerStuff.employee.image?.toImageUrlDTO(imageData: nil)
        self.employee = registerStuff.employee.toEmployeeDTO(subsidiaryId: self.subsidiary.id)
    }
}
//MARK: Sync Parameters
struct SyncCompanyParameters: Encodable {
    let updatedSince: String
    let syncIds: VerifySyncParameters
}
struct SyncImageParameters: Encodable {
    let updatedSince: String
    let syncIds: VerifySyncParameters
}
struct SyncFromCompanyParameters: Encodable {
    let companyId: UUID
    let updatedSince: String
    let syncIds: VerifySyncParameters
}
struct SyncFromSubsidiaryParameters: Encodable {
    let subsidiaryId: UUID
    let updatedSince: String
    let syncIds: VerifySyncParameters
}
//MARK: Request Parameters
struct PayCustomerDebtParameters: Codable {
    let customerId: UUID
    let amount: Int
}
struct RegisterSaleParameters: Codable {
    let subsidiaryId: UUID
    let employeeId: UUID
    let customerId: UUID?
    let paymentType: String
    let cart: CartDTO
}
