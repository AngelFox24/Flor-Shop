//
//  LogInUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/12/23.
//

import Foundation

protocol LogInUseCase {
    func execute(email: String, password: String) -> LogInStatus
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
    
    func execute(email: String, password: String) -> LogInStatus {
        var status: LogInStatus = .fail
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
                    status = .success
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
        return status
    }
    /*
    func checkDBIntegrity() {
        //Verficamos si existe un carrito del empleado default
        guard let _ = self.cartRepository.getCart() else {
            print("No se fijo el carrito LogInViewModel")
            return
        }
        //Verificamos si existe un empleado por defecto
        guard let _ = self.cartRepository.getDefaultEmployee() else {
            print("No se fijo el empleado en cartManager")
            return
        }
        //Verificamos si existe la sucursal del empleado por defecto
        guard let employeeSubsidiary: Subsidiary = self.employeeRepository.getDefaultSubsidiary() else {
            print("No se fijo la sucursal en employeeManager")
            return
        }
        //Verificamos si existe la sucursal del producto por defecto
        guard let productSubsidiary: Subsidiary = self.productReporsitory.getDefaultSubsidiary() else {
            print("No se fijo la sucursal en productManager")
            return
        }
        //Verificamos si existe la compañia de la sucursal por defecto
        guard let subsidiaryCompany: Company = self.subsidiaryRepository.getDefaulCompany() else {
            print("No se fijo la sucursal en subsidiaryManager")
            return
        }
        //Verificamos si existe la compañia por defecto
        guard let companyDefaul: Company = self.companyRepository.getDefaultCompany() else {
            print("No se fijo la compañia en companyManager")
            return
        }
        //Verificamos si existe la compañia por defecto del customer
        guard let customerCompanyDefaul: Company = self.customerRepository.getDefaultCompany() else {
            print("No se fijo la compañia en CustomerManager")
            return
        }
        if (companyDefaul.id == subsidiaryCompany.id) && (customerCompanyDefaul.id == companyDefaul.id) {
            if productSubsidiary.id == employeeSubsidiary.id {
                self.logInStatus = .success
            } else {
                print("productManager no coincide con employeeManager en Subsidiary Default")
            }
        } else {
            print("companyManager no coincide con subsidiaryManager en Company Default ni CustomerCompany")
        }
    }
    */
}
