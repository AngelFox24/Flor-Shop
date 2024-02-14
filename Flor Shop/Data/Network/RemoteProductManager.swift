//
//  RemoteProductManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 4/01/24.
//
/*
import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

protocol ReProductManager {
    func getListProducts(page: Int, completion: @escaping DownloadCompletion)
}

struct DownloadResult {
    let result: Result<[Product], APIError>
    init(_ result: Result<[Product], APIError>) {
        self.result = result
    }
}

typealias DownloadCompletion = (DownloadResult) -> ()

final class RemoteMovieManager: ReProductManager {
    static let apiKey = "55a91965afe6277c90737d0bf3d555f5"
    func getListProducts(page: Int, completion: @escaping DownloadCompletion) {
        
        guard let apiUrl = URL(string: "https://api.themoviedb.org/3/movie/upcoming?page=\(page)&api_key=\(RemoteMovieManager.apiKey)") else {
            completion(DownloadResult(.failure(.invalidURL)))
            //completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: apiUrl) { (data, response, error) in
            
            if let error = error {
                completion(DownloadResult(.failure(.networkError(error))))
                //completion(.failure(.networkError(error)))
                return
            }
            
            // Verificar si se recibieron datos
            guard let data = data else {
                completion(DownloadResult(.failure(.networkError(NSError(domain: "", code: 0, userInfo: nil)))))
                //completion(.failure(.networkError(NSError(domain: "", code: 0, userInfo: nil))))
                return
            }
            
            do {
                let trendingResults = try JSONDecoder().decode(TrendingResults.self, from: data)
                let movies = trendingResults.results
                completion(DownloadResult(.success(movies)))
                //completion(.success(movies))
            } catch {
                completion(DownloadResult(.failure(.decodingError(error))))
                //completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
*/
