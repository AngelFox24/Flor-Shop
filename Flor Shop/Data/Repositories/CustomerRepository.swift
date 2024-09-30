//
//  CustomerRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CustomerRepository {
    func save(customer: Customer) async throws
    func payClientTotalDebt(customer: Customer) throws -> Bool
    func sync() async throws
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer]
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail]
    func getCustomer(customer: Customer) throws -> Customer?
}

class CustomerRepositoryImpl: CustomerRepository, Syncronizable {
    let localManager: LocalCustomerManager
    let remoteManager: RemoteCustomerManager
    let cloudBD = true
    init(
        localManager: LocalCustomerManager,
        remoteManager: RemoteCustomerManager
    ) {
        self.localManager = localManager
        self.remoteManager = remoteManager
    }
    func sync() async throws {
        var counter = 0
        var items = 0
        
        repeat {
            print("Counter: \(counter)")
            counter += 1
            let updatedSince = self.localManager.getLastUpdated()
            let customersDTOs = try await self.remoteManager.sync(updatedSince: updatedSince)
            items = customersDTOs.count
            try self.localManager.sync(customersDTOs: customersDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    func payClientTotalDebt(customer: Customer) throws -> Bool {
        return try self.localManager.payClientTotalDebt(customer: customer)
    }
    func save(customer: Customer) async throws {
        if cloudBD {
            try await self.remoteManager.save(customer: customer)
        } else {
            try self.localManager.save(customer: customer)
        }
    }
    func getCustomers(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer] {
        return self.localManager.getCustomers(seachText: seachText, order: order, filter: filter, page: page, pageSize: pageSize)
    }
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail] {
        return self.localManager.getSalesDetailHistory(customer: customer, page: page, pageSize: pageSize)
    }
    func getCustomer(customer: Customer) throws -> Customer? {
        return try self.localManager.getCustomer(customer: customer)
    }
}
