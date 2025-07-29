import Foundation

enum BusinessLogicError: LocalizedError {
    case outOfStock(String)  // Cuando no hay stock del producto solicitado
    case duplicateProductName(String)  // Cuando ya existe un producto con el mismo nombre
    case duplicateBarCode(String)  // Cuando ya existe un producto con el mismo nombre
    var errorDescription: String? {
        switch self {
        case .outOfStock(let message),
                .duplicateProductName(let message),
                .duplicateBarCode(let message):
            return message
        }
    }
}
