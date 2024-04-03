//
//  LogOutUseCase.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 2/04/24.
//

import Foundation

protocol LogOutUseCase {
    func execute()
}

final class LogOutInteractor: LogOutUseCase {
    private let setDefaultEmployeeUseCase: SetDefaultEmployeeUseCase
    private let setDefaultSubsidiaryUseCase: SetDefaultSubsidiaryUseCase
    private let setDefaultCompanyUseCase: SetDefaultCompanyUseCase
    
    init(setDefaultEmployeeUseCase: SetDefaultEmployeeUseCase, setDefaultSubsidiaryUseCase: SetDefaultSubsidiaryUseCase, setDefaultCompanyUseCase: SetDefaultCompanyUseCase) {
        self.setDefaultEmployeeUseCase = setDefaultEmployeeUseCase
        self.setDefaultSubsidiaryUseCase = setDefaultSubsidiaryUseCase
        self.setDefaultCompanyUseCase = setDefaultCompanyUseCase
    }
    
    func execute() {
        self.setDefaultEmployeeUseCase.releaseResourses()
        self.setDefaultSubsidiaryUseCase.releaseResources()
        self.setDefaultCompanyUseCase.releaseResources()
    }
}
