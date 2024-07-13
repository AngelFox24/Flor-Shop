//
//  Employee.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

struct Employee: Identifiable {
    var id: UUID
    var name: String
    var user: String
    var email: String
    var lastName: String
    var role: String
    var image: ImageUrl?
    var active: Bool
    var phoneNumber: String
    let createdAt: Date
    let updatedAt: Date
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
    func toEmployeeDTO(subsidiaryId: UUID) -> EmployeeDTO {
        return EmployeeDTO(
            id: id,
            user: user,
            name: name,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            role: role,
            active: active,
            subsidiaryID: subsidiaryId,
            imageUrl: image?.toImageUrlDTO(),
            createdAt: createdAt.description,
            updatedAt: updatedAt.description
        )
    }
}
