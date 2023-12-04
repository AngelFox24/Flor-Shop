//
//  LogInUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol LogInUseCase {
    func execute(email: String, password: String)
}

final class LogInInteractor: LogInUseCase {
    private let employeeRepository: EmployeeRepository
    private let setDefaultEmployeeUseCase: SetDefaultEmployeeUseCase
    private let setDefaultSubsidiaryUseCase: SetDefaultSubsidiaryUseCase
    private let setDefaultCompanyUseCase: SetDefaultCompanyUseCase
    private let getCompanyUseCase: GetCompanyUseCase
    private let getSubsidiaryUseCase: GetSubsidiaryUseCase
    
    init(employeeRepository: EmployeeRepository, setDefaultEmployeeUseCase: SetDefaultEmployeeUseCase, setDefaultSubsidiaryUseCase: SetDefaultSubsidiaryUseCase, setDefaultCompanyUseCase: SetDefaultCompanyUseCase, getCompanyUseCase: GetCompanyUseCase, getSubsidiaryUseCase: GetSubsidiaryUseCase) {
        self.employeeRepository = employeeRepository
        self.setDefaultEmployeeUseCase = setDefaultEmployeeUseCase
        self.setDefaultSubsidiaryUseCase = setDefaultSubsidiaryUseCase
        self.setDefaultCompanyUseCase = setDefaultCompanyUseCase
        self.getCompanyUseCase = getCompanyUseCase
        self.getSubsidiaryUseCase = getSubsidiaryUseCase
    }
    
    func execute(email: String, password: String) {
        if let employee = self.employeeRepository.logIn(user: email, password: password) {
            print("ok employee")
            //setDefaultEmployee(employee: employee)
            self.setDefaultEmployeeUseCase.execute(employee: employee)
            if let subsidiary = self.getSubsidiaryUseCase.execute(employee: employee) {
                print("ok subsidiary")
                //setDefaultSubsidiary(subsidiary: subsidiary)
                self.setDefaultSubsidiaryUseCase.execute(subsidiary: subsidiary)
                if let company = self.getCompanyUseCase.execute(subsidiary: subsidiary) {
                    print("ok company")
                    //setDefaultCompany(company: company)
                    self.setDefaultCompanyUseCase.execute(company: company)
                } else {
                    print("Nok company")
                    //logInFields.errorLogIn = "No se encontro compañia de la sucursal"
                }
            } else {
                print("Nok subsidiary")
                //logInFields.errorLogIn = "No se encontro sucursal del empleado"
            }
        } else {
            print("Nok employee")
            //logInFields.errorLogIn = "No se encontro usuario en la BD"
        }
    }
}
