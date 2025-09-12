import SwiftUI

/// ``NavigationStack`` container that works with the ``Router``
/// to resolve the routes based on the ``Router``'s state
struct NavigationContainer<Content: View>: View {
    // The navigation container itself it's in charge of the lifecycle
    // of the router.
    @State var router: FlorShopRouter
    @Binding var showMenu: Bool
    @ViewBuilder var content: () -> Content
    @State var paddingShowMenu: CGFloat? = nil
    init(
        parentRouter: FlorShopRouter,
        tab: TabDestination? = nil,
        showMenu: Binding<Bool>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._router = .init(initialValue: parentRouter.childRouter(for: tab))
        self.content = content
        self._showMenu = showMenu ?? .constant(false)
    }

    var body: some View {
        InnerContainer(router: router) {
            content()
                .padding(.vertical, showMenu ? 20 : 0)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: showMenu ? 35 : 0, style: .continuous)
        )
        .environment(router)
        .onAppear(perform: router.setActive)
        .onDisappear(perform: router.resignActive)
        .onOpenURL(perform: openDeepLinkIfFound(for:))
    }

    func openDeepLinkIfFound(for url: URL) {
        if let destination = DeepLink.destination(from: url) {
            router.deepLinkOpen(to: destination)
        } else {
            router.logger.warning("No destination matches \(url)")
        }
    }
}

// This is necessary for getting a binder from an Environment Observable object
private struct InnerContainer<Content: View>: View {
    @Bindable var router: FlorShopRouter
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack(path: $router.navigationStackPath) {
            content()
                .navigationDestination(for: PushDestination.self) { destination in
                    view(for: destination)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                }
        }
        // it's important that the these modifiers are **outside** the `NavigationStack`
        // otherwise the content closure will be called infinitely freezing the app
        .sheet(item: $router.presentingSheet) { sheet in
            navigationView(for: sheet, from: router)
        }
        .fullScreenCover(item: $router.presentingFullScreen) { fullScreen in
            navigationView(for: fullScreen, from: router)
        }
    }

    @ViewBuilder func navigationView(for destination: SheetDestination, from router: FlorShopRouter) -> some View {
        NavigationContainer(parentRouter: router) { view(for: destination) }
    }


    @ViewBuilder func navigationView(for destination: FullScreenDestination, from router: FlorShopRouter) -> some View {
        NavigationContainer(parentRouter: router) { view(for: destination) }
    }
}

#Preview {
    NavigationContainer(parentRouter: .previewRouter()) {
        Text("Hello")
    }
}
