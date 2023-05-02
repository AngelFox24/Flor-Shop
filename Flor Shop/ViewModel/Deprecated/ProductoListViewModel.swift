//
//  ProductoListViewModel.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/04/23.
//
import Foundation

class ProductoListViewModel: ObservableObject {
    @Published var productosDiccionario: [String:ProductoModel]
    init(){
        productosDiccionario = [:]
        
        guard let url = URL(string: "http://192.168.3.72:8000/api-v1/products") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //request.addValue("application/json", forHTTPHeaderField: "Accept")

        let session = URLSession.shared

        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error al hacer la llamada a la API: \(error?.localizedDescription ?? "Desconocido")")
                return
            }
            
            if response.statusCode == 200 {
                do{
                    let productosArray = try JSONDecoder().decode([ProductoModel].self, from: data)
                    
                    for producto in productosArray {
                        self.productosDiccionario[producto.id] = producto
                    }
                    
                }catch{
                    //self.productosList = self.personajeDefaul
                    print("Error en JSONDecoder \(error)")
                }
                print(String(data: data, encoding: .utf8) ?? "Datos vacíos")
            } else {
                print("Error al hacer la llamada a la API: \(response.statusCode)")
            }
        }

        task.resume()
        
    }
}
