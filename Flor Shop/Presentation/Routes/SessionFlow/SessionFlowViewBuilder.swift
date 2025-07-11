import SwiftUI
import AppRouter

struct SessionFlow {
    @ViewBuilder
    static func getView(_ subFlow: SessionRoutes) -> some View {
        switch subFlow {
        case .loginView:
            LogInView()
        case .registrationView:
            RegistrationView()
        }
    }
}
