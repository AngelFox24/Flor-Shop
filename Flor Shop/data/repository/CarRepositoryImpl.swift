//
//  CarRepositoryImpl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation
import CoreData

protocol CarRepository {
    func getCar() -> Car
}

class CarRepositoryImpl: CarRepository {
    let manager : CarManager
    //let remote:  remoto
    
    init(manager: CarManager) {
        self.manager = manager
    }
    
    func getCar() -> Car{
        return self.manager.getCar()
    }
}
