//
//  Sale.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/05/23.
//

import Foundation

struct Sale: Identifiable {
    let id: UUID
    let saleDate: Date
    let totalSale: Double
    
    init(saleDate: Date, totalSale: Double) {
        self.id = UUID()
        self.saleDate = saleDate
        self.totalSale = totalSale
    }
}
