import SwiftUI

struct MainView: View {
    @State private var session: SessionManager
    init() {
        self.session = SessionManagerFactory.getSessionManager()
    }
    var body: some View {
        VStack {
            switch session.state {
            case .loggedOut:
                WelcomeView()
            case .loggedIn(let sessionConfig):
                MainContendView(sessionConfig: sessionConfig)
            }
        }
        .environment(session)
    }
}

struct MainContendView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var webSocket: SyncWebSocketClient
    //TODO: Verificar si no perjudica a las vistar con el repintado
    let sessionContainer: SessionContainer
    init(sessionConfig: SessionConfig) {
        self.sessionContainer = SessionContainer(sessionConfig: sessionConfig)
        self.webSocket = SyncWebSocketClientFatory.getProductViewModel(sessionContainer: sessionContainer)
    }
    var body: some View {
        VStack(spacing: 0) {
            MenuView()
                .environment(sessionContainer)
                .environment(webSocket)
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            switch newValue {
            case .active:
                webSocket.connect()
            case .inactive, .background:
                print("[WebScoket] Se desconetará por: \(newValue)")
                webSocket.disconnect()
                print("[WebScoket] Desconectado")
            default:
                webSocket.disconnect()
            }
        }
    }
}

#Preview {
    MainView()
}
