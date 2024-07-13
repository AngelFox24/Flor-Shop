//
//  Extensions.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 3/10/23.
//

import Foundation

extension Data {
    func jsonString() -> String {
        do {
            // 1. Convertir la Data a un objeto JSON (Any)
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: [])            // 2. Convertir el objeto JSON a una representación de cadena (String)
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                // 3. Imprimir la cadena formateada en la consola
                return jsonString
            } else {
                return("Error al formatear el JSON como cadena")
            }
            
        } catch {
            return "Error"
        }
    }
}

enum DateComponent {
    case day
    case month
    case year
    var numberString: String {
        switch self {
        case .day:
            return "dd"
        case .month:
            return "MM"
        case .year:
            return "YYYY"
        }
    }
}
enum DateStringNameComponent {
    case day
    case month
    var shortName: String {
        switch self {
        case .day:
            return "EEE"
        case .month:
            return "MMM"
        }
    }
    var longName: String {
        switch self {
        case .day:
            return "EEEE"
        case .month:
            return "MMMM"
        }
    }
}
extension Date {
    func getDateComponent(dateComponent: DateComponent) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateComponent.numberString

        return Int(dateFormatter.string(from: self)) ?? 0
    }
    func getShortNameComponent(dateStringNameComponent: DateStringNameComponent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES") // Establece el idioma español
        dateFormatter.dateFormat = dateStringNameComponent.shortName

        return dateFormatter.string(from: self)
    }
    func getLongNameComponent(dateStringNameComponent: DateStringNameComponent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES") // Establece el idioma español
        dateFormatter.dateFormat = dateStringNameComponent.longName

        return dateFormatter.string(from: self)
    }
}
extension String {
    func internetDateTime() -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        let dateR = isoFormatter.date(from: self)
        return dateR
    }
}
func minimunDate() -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let components = DateComponents(year: 1990, month: 1, day: 1)
    let minimunDate = calendar.date(from: components)
    return minimunDate!
}
