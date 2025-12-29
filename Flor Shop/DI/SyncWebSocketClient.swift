import Foundation
import FlorShopDTOs

struct LastTokenByEntities {
    var company: Int64
    var subsidiary: Int64
    var customer: Int64
    var employee: Int64
    var product: Int64
    var sale: Int64
    var productSubsidiary: Int64
    var employeeSubsidiary: Int64
    
    var maxGlobalToken: Int64 {
        return max(
            company,
            subsidiary,
            customer,
            employee,
            product
        )
    }
    
    var maxBranchToken: Int64 {
        return max(
            sale,
            productSubsidiary,
            employeeSubsidiary
        )
    }
}

@Observable
final class SyncWebSocketClient {
    var isConnected: Bool = false
    var lastTokenByEntities: LastTokenByEntities
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
        lastTokenByEntities: LastTokenByEntities
    ) {
        self.lastTokenByEntities = lastTokenByEntities
        self.syncManager = SyncManager(
            synchronizer: synchronizerDBUseCase,
            latestGlobalToken: lastTokenByEntities.maxGlobalToken,
            latestBranchToken: lastTokenByEntities.maxBranchToken
        )
    }
    func connect(subdomain: String, subsidiaryCic: String) async throws {
        if let task = webSocketTask,
           task.state == .running {
            print("\(logPrefix) ⚠️ WebSocket ya está conectado")
            return
        }
        let baseUrl = AppConfig.florShopCoreWSBaseURL
        let newUrl = baseUrl.replacingOccurrences(of: "{subdomain}", with: subdomain)
        guard let url = URL(string: "\(newUrl)/sync/ws") else {
            print("\(logPrefix) URL inválida: \(AppConfig.florShopCoreWSBaseURL)/sync/ws")
            return
        }
        guard let scopedToken = try? await TokenManager.shared.getToken(identifier: .scopedToken(subsidiaryCic: subsidiaryCic)) else {
            print("\(logPrefix) ⚠️ No hay scoped token para la sucursal: \(subsidiaryCic)")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(scopedToken.accessToken)", forHTTPHeaderField: "Authorization")
        webSocketTask = urlSession.webSocketTask(with: request)
        webSocketTask?.resume()
        
        isConnected = true // ✅ Se actualiza estado
        
        print("\(logPrefix) 🟢 WebSocket conectado")
        try await listen()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false // ✅ Se actualiza estado
        print("\(logPrefix) 🔴 WebSocket desconectado")
    }
    
    private func listen() async throws {
        let result = try await webSocketTask?.receive()
        switch result {
        case .data(let data):
            print("\(self.logPrefix) Mensaje binario recibido, tamaño: \(data.count)")
        case .string(let text):
            print("\(self.logPrefix) Mensaje recibido: \(text)")
            if let lastToken = self.parseSyncToken(from: text) {
                try await self.syncManager.handleNewToken(globalSyncToken: lastToken.globalToken, branchSyncToken: lastToken.branchToken)
                let newTokens = await self.syncManager.getLastTokenByEntities()
                await MainActor.run {
                    self.lastTokenByEntities = newTokens
                }
            }
        case .none, .some(_):
            print("\(self.logPrefix) Mensaje desconocido recibido")
        }
        try await self.listen()
    }
    
    private func handleWebSocketError(_ error: Error) {
        print("\(logPrefix) Error recibiendo mensaje: \(error)")

        guard let nsError = error as NSError? else { return }

        let retries = (retryByCode[nsError.code] ?? 0) + 1
        retryByCode[nsError.code] = retries

        if retries >= 5 {
            print("\(logPrefix) Demasiados errores (\(nsError.code)), cerrando socket")
            retryByCode[nsError.code] = 0
            disconnect()
        }
    }
    
    private func parseSyncToken(from json: String) -> SyncTokensDTO? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(SyncTokensDTO.self, from: data)
    }
}
