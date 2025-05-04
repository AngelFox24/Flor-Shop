//
//  MainView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/07/2024.
//

import SwiftUI

struct MainView: View {
    let dependencies: BusinessDependencies
    @EnvironmentObject var errorState: ErrorState
    @Environment(\.scenePhase) var scenePhase
    @Binding var loading: Bool
    @State var showMenu: Bool = false
    @State private var syncTask: Task<Void, Never>?
    var body: some View {
        VStack(spacing: 0) {
            MenuView(loading: $loading, showMenu: $showMenu)
                .environmentObject(dependencies.productsViewModel)
                .environmentObject(dependencies.cartViewModel)
                .environmentObject(dependencies.salesViewModel)
                .environmentObject(dependencies.customerViewModel)
                .environmentObject(dependencies.addCustomerViewModel)
                .environmentObject(dependencies.employeeViewModel)
                .environmentObject(dependencies.agregarViewModel)
                .environmentObject(dependencies.customerHistoryViewModel)
                .environmentObject(dependencies.addCustomerViewModel)
        }
        .navigationDestination(for: MenuRoutes.self) { routes in
            switch routes {
            case .customerView:
                CustomersView(backButton: true, showMenu: $showMenu)
                    .environmentObject(dependencies.customerViewModel)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .customersForPaymentView:
                CustomersView(backButton: true, showMenu: $showMenu)
                    .environmentObject(dependencies.customerViewModel)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .addCustomerView:
                AddCustomerView(loading: $loading)
                    .environmentObject(dependencies.addCustomerViewModel)
                    .environmentObject(dependencies.customerHistoryViewModel)
            case .paymentView:
                PaymentView(loading: $loading)
                    .environmentObject(dependencies.cartViewModel)
                    .environmentObject(dependencies.salesViewModel)
                
            case .customerHistoryView:
                CustomerHistoryView(loading: $loading)
                    .environmentObject(dependencies.customerHistoryViewModel)
                    .environmentObject(dependencies.addCustomerViewModel)
            }
        }
        .onAppear {
            if scenePhase == .active {
                print("=====================OnAppear Schedule a Task to Sync=====================")
                syncTask?.cancel()
                syncTask = Task(priority: .background) {
                    await syncInBackground()
                }
            }
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                print("=====================OnChange Schedule a Task to Sync=====================")
                syncTask?.cancel()
                syncTask = Task(priority: .background) {
                    await syncInBackground()
                }
            case .inactive:
                syncTask?.cancel()
            case .background:
                syncTask?.cancel()
            default:
                syncTask?.cancel()
            }
        }
    }
    private func syncInBackground() async {
        while !Task.isCancelled {
//            print("=====================Synchronizing...=====================")
            let lastDate = await dependencies.synchronizerDBUseCase.lastSyncDate
            if let lastDateSync = lastDate {
                let now = Date()
                let differenceInSeconds = now.timeIntervalSince(lastDateSync)
                if differenceInSeconds >= 3 {//3 segundos
                    do {
                        try await dependencies.synchronizerDBUseCase.sync()
//                        print("=====================Syncronized=====================")
                    } catch {
                        await errorState.processError(error: error)
                    }
                }
            } else {
                do {
                    try await dependencies.synchronizerDBUseCase.sync()
//                    print("=====================Syncronized=====================")
                } catch {
                    await errorState.processError(error: error)
                }
            }
            // Esperar 5 segundos
            try? await Task.sleep(nanoseconds: 5_000_000_000)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let normalDependencies = NormalDependencies()
        let sesC = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dep = BusinessDependencies(sessionConfig: sesC)
        @State var loading = false
        MainView(dependencies: dep, loading: $loading)
            .environmentObject(normalDependencies.navManager)
            .environmentObject(normalDependencies.versionCheck)
            .environmentObject(normalDependencies.logInViewModel)
            .environmentObject(normalDependencies.errorState)
    }
}
