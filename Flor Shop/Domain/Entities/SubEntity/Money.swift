//
//  Money.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

struct Money: Codable {
    var cents: Int
    
    // Inicializador para deserialización directa desde un valor entero
    init(_ cents: Int) {
        self.cents = cents
    }
    
    // Propiedad computada para obtener el valor en soles (opcional, según necesidad)
    var soles: Double {
        return Double(cents) / 100.0
    }
    
    // Implementación de Codable para personalizar la serialización
    private enum CodingKeys: String, CodingKey {
        case cents
    }
    
    // Método para convertir a JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(cents)
    }
    
    // Método para convertir desde JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        cents = try container.decode(Int.self)
    }
}
