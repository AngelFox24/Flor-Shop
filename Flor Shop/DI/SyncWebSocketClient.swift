//
//  SyncWebSocketClient.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 17/05/2025.
//

import Foundation
import Observation

@Observable
final class SyncWebSocketClient {
    var isConnected: Bool = false
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    //Log Prefix
    private let logPrefix = "[WebSocket]"
    //Manager
    private let syncManager: SyncManager
    //Handle retries
    private var retryByCode: [Int: Int] = [:]
    init(
        synchronizerDBUseCase: SynchronizerDBUseCase,
        latestToken: Int64
    ) {
        self.syncManager = SyncManager(
            synchronizer: synchronizerDBUseCase,
            latestToken: latestToken
        )
    }
    func connect() {
        if let task = webSocketTask,
           task.state == .running {
            print("\(logPrefix) ⚠️ WebSocket ya está conectado")
            return
        }

        guard let url = URL(string: "\(AppConfig.wsBaseURL)\(APIEndpoint.Sync.webSocekt)") else {
            print("\(logPrefix) URL inválida")
            return
        }

        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true // ✅ Se actualiza estado
        
        listen()
        print("\(logPrefix) 🔗 WebSocket conectado")
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false // ✅ Se actualiza estado
        print("\(logPrefix) 🔴 WebSocket desconectado")
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                self.handleWebSocketError(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    print("\(self.logPrefix) Mensaje recibido: \(text)")
                    if let lastToken = self.parseSyncToken(from: text) {
                        Task {
                            await self.syncManager.handleNewToken(lastToken)
                        }
                    }
                case .data(let data):
                    print("\(self.logPrefix) Mensaje binario recibido, tamaño: \(data.count)")
                @unknown default:
                    print("\(self.logPrefix) Mensaje desconocido recibido")
                }
            }
            
            // Volver a escuchar
            self.listen()
        }
    }
    
    func send(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("\(self.logPrefix) Error enviando mensaje: \(error)")
            }
        }
    }
    
    private func handleWebSocketError(_ error: Error) {
        print("\(self.logPrefix) Error recibiendo mensaje: \(error)")

        if let nsError = error as NSError? {
            self.retryByCode[nsError.code, default: 0] += 1
            if self.retryByCode[nsError.code, default: 0] < 5 {
                print("\(self.logPrefix) Desconectado por muchos reintentos del error \(nsError.code)")
                self.disconnect()
                self.retryByCode[nsError.code] = 0
            }
        }
    }
    
    private func parseSyncToken(from json: String) -> Int64? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(Int64.self, from: data)
    }
}
