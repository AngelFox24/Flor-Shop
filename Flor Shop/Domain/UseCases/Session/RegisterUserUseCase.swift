//
//  RegisterUserUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

//import Foundation
//
//protocol RegisterUserUseCase {
//    func execute(company: Company, subsidiary: Subsidiary, employee: Employee) -> Bool
//}
//
//final class RegisterUserInteractor: RegisterUserUseCase {
//   
//    private let createCompanyUseCase: CreateCompanyUseCase
//    private let createSubsidiaryUseCase: CreateSubsidiaryUseCase
//    private let createEmployeeUseCase: CreateEmployeeUseCase
//    private let setDefaultCompanyUseCase : SetDefaultCompanyUseCase
////    private let setDefaultSubsidiaryUseCase : SetDefaultSubsidiaryUseCase
//    private let setDefaultEmployeeUseCase : SetDefaultEmployeeUseCase
//    
//    init(
//        createCompanyUseCase: CreateCompanyUseCase,
//        createSubsidiaryUseCase: CreateSubsidiaryUseCase,
//        createEmployeeUseCase: CreateEmployeeUseCase,
//        setDefaultCompanyUseCase: SetDefaultCompanyUseCase,
////        setDefaultSubsidiaryUseCase: SetDefaultSubsidiaryUseCase,
//        setDefaultEmployeeUseCase: SetDefaultEmployeeUseCase
//    ) {
//        self.createCompanyUseCase = createCompanyUseCase
//        self.createSubsidiaryUseCase = createSubsidiaryUseCase
//        self.createEmployeeUseCase = createEmployeeUseCase
//        self.setDefaultCompanyUseCase = setDefaultCompanyUseCase
////        self.setDefaultSubsidiaryUseCase = setDefaultSubsidiaryUseCase
//        self.setDefaultEmployeeUseCase = setDefaultEmployeeUseCase
//    }
//    
//    func execute(company: Company, subsidiary: Subsidiary, employee: Employee) -> Bool {
//        if self.createCompanyUseCase.execute(company: company) {
//            self.setDefaultCompanyUseCase.execute(company: company)
//            if self.createSubsidiaryUseCase.execute(subsidiary: subsidiary) {
//                self.setDefaultSubsidiaryUseCase.execute(subsidiary: subsidiary)
//                if self.createEmployeeUseCase.execute(employee: employee) {
//                    self.setDefaultEmployeeUseCase.execute(employee: employee)
//                    print("Register Ok")
//                    return true
//                } else {
//                    print("Empleado ya existe en la BD")
//                    return false
//                }
//            } else {
//                //registrationFields.errorRegistration = "Sucursal ya existe en la BD"
//                print("Sucursal ya existe en la BD")
//                return false
//            }
//        } else {
//            //registrationFields.errorRegistration = "Compañia ya existe en la BD"
//            print("Compañia ya existe en la BD")
//            return false
//        }
//    }
//}
