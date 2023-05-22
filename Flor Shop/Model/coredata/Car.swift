//
//  Car.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation

struct Car: Identifiable {
    let id: UUID
    let dateCar: Date
    let total: Double
    
    init(dateCar: Date, total: Double) {
        self.id = UUID()
        self.dateCar = dateCar
        self.total = total
    }
}
