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
    let registerSaleUseCase: RegisterSaleUseCase
    let getSalesUseCase: GetSalesUseCase
    init(registerSaleUseCase: RegisterSaleUseCase, getSalesUseCase: GetSalesUseCase) {
        self.registerSaleUseCase = registerSaleUseCase
        self.getSalesUseCase = getSalesUseCase
        fetchVentas()
    }
    func fetchVentas () {
        salesCoreData = self.getSalesUseCase.execute(page: 1)
    }
    func registerSale(cart: Car?, customer: Customer?) -> Bool {
        return self.registerSaleUseCase.execute(cart: cart, customer: customer)
    }
}
