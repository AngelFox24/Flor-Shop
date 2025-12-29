import Foundation
actor SyncManager {
    private var isSyncing = false
    
    private var previousGlobalToken: Int64
    private var previousBranchToken: Int64
    
    private var latestGlobalToken: Int64
    private var latestBranchToken: Int64
    
    private let synchronizer: SynchronizerDBUseCase
    private let logPrefix: String = "[WebSocket]"

    init(
        synchronizer: SynchronizerDBUseCase,
        latestGlobalToken: Int64,
        latestBranchToken: Int64
    ) {
        self.synchronizer = synchronizer
        self.latestGlobalToken = latestGlobalToken
        self.latestBranchToken = latestBranchToken
        self.previousGlobalToken = latestGlobalToken
        self.previousBranchToken = latestBranchToken
    }
    
    func handleNewToken(globalSyncToken: Int64?, branchSyncToken: Int64?) async throws {
        if let globalSyncToken {
            latestGlobalToken = globalSyncToken
        }
        if let branchSyncToken {
            latestBranchToken = branchSyncToken
        }
        if !isSyncing {
            print("\(logPrefix) Se inició la sincronización ...")
            try await syncNext()
        }
    }
    
    func getLastTokenByEntities() async -> LastTokenByEntities {
        return self.synchronizer.getLastToken()
    }
    
    private func syncNext() async throws {
        //Reservamos el ultimo token local
        let previousGlobalToken = self.previousGlobalToken
        let latestGlobalToken = self.latestGlobalToken
        let previousBranchToken = self.previousBranchToken
        let latestBranchToken = self.latestBranchToken
        guard previousGlobalToken != latestGlobalToken || previousBranchToken != latestBranchToken else {
            print("\(logPrefix) Mismo parametros, no se sincroniza.")
            print("\(logPrefix) Los parametros son: previousGlobalToken: \(previousGlobalToken), latestGlobalToken: \(latestGlobalToken), previousBranchToken: \(previousBranchToken), latestBranchToken: \(latestBranchToken)")
            return
        }
        isSyncing = true
        
        let lastTokenUpdate = try await synchronizer.sync(globalSyncToken: previousGlobalToken, branchSyncToken: previousBranchToken)
        try await self.verifySyncCompletion(
            lastGlobalTokenUpdate: lastTokenUpdate.globalSyncToken,
            lastBranchTokenUpdate: lastTokenUpdate.branchSyncToken,
            targetGlobalToken: latestGlobalToken,
            targetBranchToken: latestBranchToken
        )
        self.previousGlobalToken = latestGlobalToken
        self.previousBranchToken = latestBranchToken
        print("\(logPrefix) ✅ Sincronización completa")
        try await self.syncCompleted()
    }
    
    private func verifySyncCompletion(lastGlobalTokenUpdate: Int64, lastBranchTokenUpdate: Int64, targetGlobalToken: Int64, targetBranchToken: Int64) async throws {
        if lastGlobalTokenUpdate < targetGlobalToken || lastBranchTokenUpdate < targetBranchToken {
            self.previousGlobalToken = lastGlobalTokenUpdate
            self.previousBranchToken = lastBranchTokenUpdate
            print("\(logPrefix) Se inició la sincronización porque el token de la respuesta anterior no es el último, objetivo global es: \(targetGlobalToken) branch es \(targetBranchToken), actual global es: \(lastGlobalTokenUpdate) branch es: \(lastBranchTokenUpdate) ...")
            try await syncNext()
        } else {
            print("\(logPrefix) Sincronizacion completa, se verificara si hay nuevos cambios mientras se estaba sincronizando ...")
            return
        }
    }
    
    private func syncCompleted() async throws {
        isSyncing = false
        guard previousGlobalToken != latestGlobalToken || previousBranchToken != latestBranchToken else {
            print("\(logPrefix) No hay nuevos cambios para syncronizar mientras sincronizaba ...")
            return
        }
        print("\(logPrefix) Se inició la sincronización de una respuesta anterior ...")
        try await syncNext()
    }
}
