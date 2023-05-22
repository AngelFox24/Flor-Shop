//
//  SaleRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol SaleRepository {
    func registerSale(car: Car) -> Bool
    func getListSales() -> [Sale]
}

class SaleRepositoryImpl: SaleRepository {
    
    let manager : SaleManager
    //let remote:  remoto, se puede implementar el remoto aqui
    
    init(manager: SaleManager) {
        self.manager = manager
    }
    
    func registerSale(car: Car) -> Bool {
        return self.manager.registerSale(car: car)
    }
    
    func getListSales() -> [Sale] {
        //add to remote logic
        return self.manager.getListSales()
    }
}
