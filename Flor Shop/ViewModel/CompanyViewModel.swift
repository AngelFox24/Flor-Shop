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
        self.managerPerson = managerRepository.getManager()
        if self.managerPerson == nil {
            managerRepository.addManager(manager: Manager(id: UUID(uuidString: "MA001") ?? UUID(), name: "Angel", lastName: "Curi Laurente"))
            self.managerPerson = managerRepository.getManager()
            if managerPerson == nil {
                print("Error al crear Admin")
            }
        }
        self.company = companyRepository.getCompany()
        guard let managerLocal = managerPerson else {
            print("Error al crear Compañia, no hay Manager")
            return
        }
        if self.company == nil {
            companyRepository.addCompany(company: Company(id: UUID(uuidString: "CO001") ?? UUID(), companyName: "Cindy", ruc: "Jarpi Menestra"), manager: managerLocal)
            self.company = companyRepository.getCompany()
            if self.company == nil {
                print("Error al crear Compañia")
            }
        }
        guard let companyLocal = company else {
            print("Error al crear Subsidiaria, no hay Compañia")
            return
        }
        self.subsidiary = subsidiaryRepository.getSubsidiary()
        if self.subsidiary == nil {
            //Creamos una sucursal
            subsidiaryRepository.addSubsidiary(subsidiary: Subsidiary(id: UUID(uuidString: "SU001") ?? UUID(), name: "Tienda Flor", image: ImageUrl(id: UUID(uuidString: "IM001") ?? UUID(), imageUrl: "https://img.freepik.com/vector-premium/ilustracion-vector-fachada-tienda-abarrotes-escaparate-edificio-tienda-vista-frontal-fachada-tienda-dibujos-animados-plana-eps-10_505557-737.jpg?w=2000")), company: companyLocal)
            self.subsidiary = subsidiaryRepository.getSubsidiary()
            if self.subsidiary == nil {
                print("Error al crear Subsidiaria")
            }
            //Si la sucursal recien se ha creado hay que crear el primer empleado
        }
    }
    // MARK: CRUD Core Data
}
