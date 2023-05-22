//
//  VentasCoreDataViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 8/05/23.
//
import CoreData
import Foundation


class VentasCoreDataViewModel: ObservableObject {
    @Published var ventasCoreData: [Sale] = []
    let saleRepository: SaleRepository
    
    init(saleRepository: SaleRepository){
        self.saleRepository = saleRepository
        fetchVentas()
    }
    //MARK: CRUD Core Data
    func fetchVentas () {
        ventasCoreData = self.saleRepository.getListSales()
    }
    
    func registrarVenta() -> Bool {
        return saleRepository.registerSale()
    }
}
