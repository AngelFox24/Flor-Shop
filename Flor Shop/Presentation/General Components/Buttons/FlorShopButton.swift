import SwiftUI

struct FlorShopButton: View {
    @Environment(Router.self) private var router
    @Environment(SyncWebSocketClient.self) private var ws
    @State private var isScaled = false
    @AppStorage("hasShownSideBar") private var hasShownSideBar: Bool = false
    var body: some View {
        ZStack(content: {
            Button(action: {
                withAnimation(.spring()){
                    router.showMenu.toggle()
                    if !hasShownSideBar {
                        hasShownSideBar = true
                    }
                }
            }, label: {
                HStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                }
                .background(Color.launchBackground)
                .cornerRadius(10)
                .frame(width: 40, height: 40)
            })
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    if ws.isConnected {
                        Color.green
                            .frame(width: 7, height: 7)
                            .cornerRadius(5)
                            .padding(.horizontal, 4)
                    } else {
                        
                        Color.red
                            .frame(width: 7, height: 7)
                            .cornerRadius(5)
                            .padding(.horizontal, 4)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
                Spacer()
            }
            .frame(width: 40, height: 40)
            if !hasShownSideBar {
                VStack(alignment: .center, spacing: 0, content: {
                    Spacer()
                    HStack(content: {
                        Spacer()
                        Color.yellow
                            .frame(width: 7, height: 7)
                            .cornerRadius(5)
                            .padding(.horizontal, 4)
                            .scaleEffect(isScaled ? 1.5 : 1.0)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                    self.isScaled.toggle()
                                }
                            }
                    })
                    .padding(.vertical, 4)
                })
                .frame(width: 40, height: 40)
            }
        })
    }
}

#Preview {
    @Previewable @State var router = Router()
    @Previewable @State var ws = SyncWebSocketClient(
        synchronizerDBUseCase: SynchronizerDBInteractorMock(),
        lastTokenByEntities: LastTokenByEntities(
            image: 0,
            company: 0,
            subsidiary: 0,
            customer: 0,
            employee: 0,
            product: 0,
            sale: 0
        )
    )
    FlorShopButton()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
        .environment(router)
        .environment(ws)
}
