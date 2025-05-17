//
//  SyncManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 17/05/2025.
//
import Foundation
actor SyncManager {
    private var isSyncing = false
    private var latestParams: VerifySyncParameters?
    private let synchronizer: SynchronizerDBUseCase
    private let logPrefix: String = "[WebSocket]"

    init(synchronizer: SynchronizerDBUseCase) {
        self.synchronizer = synchronizer
    }

    func handleNewParams(_ params: VerifySyncParameters) async {
        latestParams = params
        if !isSyncing {
            await syncNext()
        }
    }
    
    private func syncNext() async {
        guard let params = latestParams else { return }
        
        isSyncing = true
        latestParams = nil
        
        do {
            try await synchronizer.sync(verifySyncParameters: params)
            print("\(logPrefix) ✅ Sincronización completa")
        } catch {
            print("\(logPrefix) ❌ Error sync: \(error)")
        }
        
        await self.syncCompleted()
    }
    
    private func syncCompleted() async {
        isSyncing = false
        if latestParams != nil {
            await syncNext()
        }
    }
}
