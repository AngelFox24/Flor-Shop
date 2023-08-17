//
//  CompanyViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 17/08/23.
//

import Foundation
import Foundation

class CompanyViewModel: ObservableObject {
    @Published var managerPerson: Manager?
    @Published var company: Company?
    @Published var subsidiary: Subsidiary?
    let managerRepository: ManagerRepository
    let companyRepository: CompanyRepository
    let subsidiaryRepository: SubsidiaryRepository
    init(managerRepository: ManagerRepository, companyRepository: CompanyRepository, subsidiaryRepository: SubsidiaryRepository) {
        self.managerRepository = managerRepository
        self.companyRepository = companyRepository
        self.subsidiaryRepository = subsidiaryRepository
        //Check if everything necessary is created
        managerPerson = managerRepository.getManager()
    }
    // MARK: CRUD Core Data
}
