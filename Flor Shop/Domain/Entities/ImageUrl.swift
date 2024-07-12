//
//  ImageUrl.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 16/08/23.
//

import Foundation

struct ImageUrl: Identifiable, Codable {
    var id: UUID
    var imageUrl: String
    var imageHash: String
}
