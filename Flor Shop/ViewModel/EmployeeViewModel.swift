//
//  EmployeeViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 27/09/23.
//

import Foundation

class EmployeeViewModel: ObservableObject {
    @Published var employeeList: [Employee] = []
    private let employeeRepository: EmployeeRepository
    init(employeeRepository: EmployeeRepository) {
        self.employeeRepository = employeeRepository
    }
    // MARK: CRUD Core Data
    func fetchListEmployees() {
        employeeList = employeeRepository.getEmployees()
    }
    func lazyFetchList() {
        if employeeList.isEmpty {
            fetchListEmployees()
        }
    }
}
