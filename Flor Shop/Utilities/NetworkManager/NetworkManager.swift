import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func perform<T: Decodable>(_ request: NetworkRequest, decodeTo type: T.Type) async throws -> T {
        let urlRequest = try request.urlRequest()
        print("-----------------------------------✅Se encontro una peticion✅------------------------------------")
        let (data, response) = try await urlSession.data(for: urlRequest)
        print(data.jsonString())
        print("-----------------------------------✅Termino de la peticion✅------------------------------------")
        try processResponse(response: response, data: data)
        return try decodeData(data: data, type: T.self)
    }
    
    private func decodeData<T: Decodable>(data: Data, type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decodedObject = try decoder.decode(T.self, from: data)
            return decodedObject
        } catch let decodingError {
            print("Error al decodificar: \(decodingError.localizedDescription)")
            throw NetworkError.decodingFailed(decodingError)
        }
    }
    
    private func processResponse(response: URLResponse?, data: Data? = nil) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 404:
            throw NetworkError.notFound
        case 500:
            throw NetworkError.internalServerError
        default:
            throw NetworkError.unknownError(statusCode: httpResponse.statusCode)
        }
    }
    
    func downloadFile(from url: URL) async throws -> URL {
        let (localURL, response) = try await urlSession.download(from: url)
        try processResponse(response: response)
        return localURL
    }
}
