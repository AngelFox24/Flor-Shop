//
//  SyncWebSocketClient.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 17/05/2025.
//

import Foundation

class SyncWebSocketClient {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession = URLSession(configuration: .default)
    //Log Prefix
    private let logPrefix = "[WebSocket]"
    //Manager
    private let syncManager: SyncManager
    init(
        synchronizerDBUseCase: SynchronizerDBUseCase
    ) {
        self.syncManager = SyncManager(synchronizer: synchronizerDBUseCase)
    }
    func connect() {
        if let task = webSocketTask,
           task.state == .running {
            print("\(logPrefix) ⚠️ WebSocket ya está conectado")
            return
        }

        guard let url = URL(string: "wss://pizzarely.mrangel.dev/verifySync/ws") else {
            print("\(logPrefix) URL inválida")
            return
        }

        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        
        listen()
        print("\(logPrefix) 🔗 WebSocket conectado")
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("\(logPrefix) 🔴 WebSocket desconectado")
    }
    
    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("\(self.logPrefix) Error recibiendo mensaje: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("\(self.logPrefix) Mensaje recibido: \(text)")
                    if let params = self.parseSyncParameters(from: text) {
                        Task {
                            await self.syncManager.handleNewParams(params)
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
    
    private func parseSyncParameters(from json: String) -> VerifySyncParameters? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(VerifySyncParameters.self, from: data)
    }
}
