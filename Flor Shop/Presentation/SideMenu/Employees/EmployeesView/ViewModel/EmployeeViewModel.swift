//
//  EmployeeViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 27/09/23.
//

import Foundation

class EmployeeViewModel: ObservableObject {
    @Published var employeeList: [Employee] = []
    private let getEmployeesUseCase: GetEmployeesUseCase
    init(getEmployeesUseCase: GetEmployeesUseCase) {
        self.getEmployeesUseCase = getEmployeesUseCase
        fetchListEmployees()
    }
    // MARK: CRUD Core Data
    func fetchListEmployees() {
        self.employeeList = self.getEmployeesUseCase.execute(page: 1)
    }
    func lazyFetchList() {
        if employeeList.isEmpty {
            fetchListEmployees()
        }
    }
}
