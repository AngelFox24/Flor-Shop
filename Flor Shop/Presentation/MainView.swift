import SwiftUI

struct MainView: View {
    @Environment(LogInViewModel.self) var logInViewModel
    @Environment(PersistenceSessionConfig.self) private var sessionConfig
    var body: some View {
        VStack {
            if let sessionConfig = sessionConfig.session {
                MainContendView(sessionConfig: sessionConfig)
            } else {
                WelcomeView()
            }
        }
    }
}

struct MainContendView: View {
    let sessionConfig: SessionConfig
    let dependencies: BusinessDependencies
    @Environment(\.scenePhase) var scenePhase
    init(sessionConfig: SessionConfig) {
        self.sessionConfig = sessionConfig
        self.dependencies = BusinessDependencies(sessionConfig: sessionConfig)
    }
    var body: some View {
        VStack(spacing: 0) {
            MenuView()
                .environment(dependencies.productViewModel)
                .environment(dependencies.cartViewModel)
                .environment(dependencies.salesViewModel)
                .environment(dependencies.customerViewModel)
                .environment(dependencies.addCustomerViewModel)
                .environment(dependencies.employeeViewModel)
                .environment(dependencies.agregarViewModel)
                .environment(dependencies.customerHistoryViewModel)
                .environment(dependencies.addCustomerViewModel)
                .environment(dependencies.webSocket)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .active:
                dependencies.webSocket.connect()
            case .inactive, .background:
                print("[WebScoket] Se desconetará por: \(newValue)")
                dependencies.webSocket.disconnect()
                print("[WebScoket] Desconectado")
            default:
                dependencies.webSocket.disconnect()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let normalDependencies = NormalDependencies()
        MainView()
            .environment(normalDependencies.logInViewModel)
    }
}
