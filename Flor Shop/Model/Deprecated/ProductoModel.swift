//
//  ProductoModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/04/23.
//

import Foundation

// MARK: - ProductoElement
struct ProductoModel: Codable,Identifiable {
    
    let id: String
    var expiredate: String
    let imageURL: String
    let name: String
    let price: Double
    let quantity: Int
}
