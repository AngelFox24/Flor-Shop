//
//  CustomerRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation
import CoreData

protocol CustomerRepository {
    func sync() async throws
    func addCustomer(customer: Customer) -> String
    func getCustomersList(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer]
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail]
    func updateCustomer(customer: Customer)
    func deleteCustomer(customer: Customer)
    func filterCustomer(word: String) -> [Customer]
    func setOrder(order: CustomerOrder)
    func setFilter(filter: CustomerFilterAttributes)
    func getCustomer(customer: Customer) -> Customer?
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
            guard let updatedSince = try localManager.getLastUpdated() else {
                throw RepositoryError.invalidFields(("El campo updatedSince no se encuentra"))
            }
            let updatedSinceString = ISO8601DateFormatter().string(from: updatedSince)
            let customersDTOs = try await self.remoteManager.sync(updatedSince: updatedSinceString)
            items = customersDTOs.count
            try self.localManager.sync(customersDTOs: customersDTOs)
        } while (counter < 10 && items == 50) //El limite de la api es 50 asi que menor a eso ya no hay mas productos a actualiar
    }
    //C - Create
    func addCustomer(customer: Customer) -> String {
        return self.localManager.addCustomer(customer: customer)
    }
    //R - Read
    func getCustomersList(seachText: String, order: CustomerOrder, filter: CustomerFilterAttributes, page: Int, pageSize: Int) -> [Customer] {
        return self.localManager.getCustomersList(seachText: seachText, order: order, filter: filter, page: page, pageSize: pageSize)
    }
    func getSalesDetailHistory(customer: Customer, page: Int, pageSize: Int) -> [SaleDetail] {
        return self.localManager.getSalesDetailHistory(customer: customer, page: page, pageSize: pageSize)
    }
    func getCustomer(customer: Customer) -> Customer? {
        return self.localManager.getCustomer(customer: customer)
    }
    //U - Update
    func updateCustomer(customer: Customer) {
        self.localManager.updateCustomer(customer: customer)
    }
    //D - Delete
    func deleteCustomer(customer: Customer) {
        self.localManager.deleteCustomer(customer: customer)
    }
    func filterCustomer(word: String) -> [Customer] {
        return self.localManager.filterCustomer(word: word)
    }
    func setOrder(order: CustomerOrder) {
        self.localManager.setOrder(order: order)
    }
    func setFilter(filter: CustomerFilterAttributes) {
        self.localManager.setFilter(filter: filter)
    }
}
