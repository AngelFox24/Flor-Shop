//
//  Extensions.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 3/10/23.
//

import Foundation
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
