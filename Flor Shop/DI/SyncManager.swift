//
//  SyncManager.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 17/05/2025.
//
import Foundation
actor SyncManager {
    private var isSyncing = false
    private var previousToken: Int64
    private var latestToken: Int64
    private let synchronizer: SynchronizerDBUseCase
    private let logPrefix: String = "[WebSocket]"

    init(
        synchronizer: SynchronizerDBUseCase,
        latestToken: Int64
    ) {
        self.synchronizer = synchronizer
        self.latestToken = latestToken
        self.previousToken = latestToken
    }
    
    func handleNewToken(_ token: Int64) async {
        latestToken = token
        if !isSyncing {
            print("\(logPrefix) Se inició la sincronización ...")
            await syncNext()
        }
    }
    
    private func syncNext() async {
        //Reservamos el ultimo token local
        let previousToken = self.previousToken
        let latestToken = self.latestToken
        guard previousToken != latestToken else {
            print("\(logPrefix) Mismo parametros, no se sincroniza.")
            return
        }
        isSyncing = true
        
        do {
            let lastTokenUpdate = try await synchronizer.sync(lastToken: previousToken)
            await self.verifySyncCompletion(lastTokenUpdate: lastTokenUpdate, targetToken: latestToken)
            self.previousToken = latestToken
            print("\(logPrefix) ✅ Sincronización completa")
        } catch {
            print("\(logPrefix) ❌ Error sync: \(error)")
        }
        await self.syncCompleted()
    }
    
    private func verifySyncCompletion(lastTokenUpdate: Int64, targetToken: Int64) async {
        if lastTokenUpdate < targetToken {
            self.previousToken = lastTokenUpdate
            print("\(logPrefix) Se inició la sincronización porque el token de la respuesta anterior no es el último, obejtivo es: \(targetToken), actual: \(lastTokenUpdate) ...")
            await syncNext()
        } else {
            print("\(logPrefix) Sincronizacion completa, se verificara si hay nuevos cambios mientras se estaba sincronizando ...")
            return
        }
    }
    
    private func syncCompleted() async {
        isSyncing = false
        guard previousToken != latestToken else {
            print("\(logPrefix) No hay nuevos cambios para syncronizar mientras sincronizaba ...")
            return
        }
        print("\(logPrefix) Se inició la sincronización de una respuesta anterior ...")
        await syncNext()
    }
}
