import Foundation

enum NetworkError: LocalizedError {
    case badURL
    case requestFailed(Error)
    case invalidResponse
    case dataNotFound
    case decodingFailed(Error)
    case encodingFailed(Error)
    case notFound
    case internalServerError
    case unknownError(statusCode: Int)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "La URL proporcionada no es válida."
        case .requestFailed(let error):
            return "La solicitud falló: \(error.localizedDescription)"
        case .invalidResponse:
            return "La respuesta del servidor no es válida."
        case .dataNotFound:
            return "No se encontraron datos en la respuesta."
        case .decodingFailed(let error):
            return "Falló la decodificación de datos: \(error.localizedDescription)"
        case .encodingFailed(let error):
            return "Falló la codificación de datos: \(error.localizedDescription)"
        case .notFound:
            return "Recurso no encontrado (404)."
        case .internalServerError:
            return "Error interno del servidor (500)."
        case .unknownError(let code):
            return "Error desconocido. Código: \(code)"
        case .serverError(let reason):
            return reason
        }
    }
}
