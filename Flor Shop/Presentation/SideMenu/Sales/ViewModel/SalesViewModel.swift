//
//  VentasCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 8/05/23.
//
import CoreData
import Foundation

class SalesViewModel: ObservableObject {
    @Published var salesCoreData: [Sale] = []
    let saleRepository: SaleRepository
    init(saleRepository: SaleRepository) {
        self.saleRepository = saleRepository
        fetchVentas()
    }
    // MARK: CRUD Core Data
    func fetchVentas () {
        salesCoreData = self.saleRepository.getListSales()
    }
    func registerSale(cart: Car?, customer: Customer?) -> Bool {
        return saleRepository.registerSale(cart: cart, customer: customer)
    }
}
