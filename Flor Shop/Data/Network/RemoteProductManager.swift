
//  RemoteProductManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/01/24.

import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidFields(String)
}

protocol ReProductManager {
    func checkConectivity() async throws -> Bool
    func save(subsidiaryId: UUID, product: Product) async throws -> Bool
    func sync(productRequest: ProductRequest) async throws -> [Product]
}

final class RemoteProductManager: ReProductManager {
    func checkConectivity() async throws -> Bool {
        print("Se verificara la conexion")
        guard let apiUrl = URL(string: "http://192.168.2.15:8080/companies") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.networkError(NSError(domain: "", code: 0, userInfo: nil))
        }
        print("Data: \(data)")
        return true
    }
    func save(subsidiaryId: UUID, product: Product) async throws -> Bool {
        print("Se guardar en Red")
        guard let apiUrl = URL(string: "http://192.168.2.15:8080/products") else {
            throw APIError.invalidURL
        }
        
        // Crear el cuerpo del JSON a enviar
        let productJSON = try JSONEncoder().encode(product.toProductDTO(subsidiaryId: subsidiaryId))
        // 1. Convertir la Data a un objeto JSON (Any)
        let jsonObject = try JSONSerialization.jsonObject(with: productJSON, options: [])

        // 2. Convertir el objeto JSON a una representación de cadena (String)
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            // 3. Imprimir la cadena formateada en la consola
            print("Product Data JSON: \(jsonString)")
        } else {
            print("Error al formatear el JSON como cadena")
        }
        
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = productJSON
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.networkError(NSError(domain: "", code: 0, userInfo: nil))
        }
        return true
    }
    func sync(productRequest: ProductRequest) async throws -> [Product] {
        guard let apiUrl = URL(string: "http://192.168.2.15:8080/products/sync") else {
            throw APIError.invalidURL
        }
        print("Se va a codificar ProductRequest")
        let requestBody = try JSONEncoder().encode(productRequest)
        print("Se codifico ProductRequest exitosamente")
        // 1. Convertir la Data a un objeto JSON (Any)
        let jsonObject = try JSONSerialization.jsonObject(with: requestBody, options: [])

        // 2. Convertir el objeto JSON a una representación de cadena (String)
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            // 3. Imprimir la cadena formateada en la consola
            print("Product Data JSON: \(jsonString)")
        } else {
            print("Error al formatear el JSON como cadena")
        }
        print("Se creara el request")
        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        print("Se consultara a la API")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("Se consulto a la API")
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("La respuesta no es 200")
            throw APIError.networkError(NSError(domain: "", code: 0, userInfo: nil))
        }
        
        do {
            print("Se decodificara Product desde la API")
            let productsDTO = try JSONDecoder().decode([ProductDTO].self, from: data)
            print("Se termino de decodificar")
            return productsDTO.mapToListProducts()
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
