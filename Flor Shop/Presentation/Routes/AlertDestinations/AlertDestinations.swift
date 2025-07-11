import SwiftUI
import AppRouter
public struct AlertDestinations: ViewModifier {
    @Binding var router: Router
    public func body(content: Content) -> some View {
        content.overlay(
            Group {
                if let presentedAlert = router.presentedAlert {
                    switch presentedAlert {
                    case .error(let error):
                        ErrorView(error: error)
                    case .wsError:
                        WebSocketErrorView()
                    }
                }
            }
        )
    }
}

extension View {
    func withAlertDestinations(router: Binding<Router>) -> some View {
        modifier(
            AlertDestinations(
                router: router
            )
        )
    }
}
