import SwiftUI

struct AlertInfo {
    struct ButtonConfig {
        let text: String
        let action: () -> Void
    }
    let tittle: String
    let message: String
    let mainButton: ButtonConfig
    let secondButton: ButtonConfig?
    init(
        tittle: String,
        message: String,
        mainButton: ButtonConfig,
        secondButton: ButtonConfig? = nil
    ) {
        self.tittle = tittle
        self.message = message
        self.mainButton = mainButton
        self.secondButton = secondButton
    }
}

struct AppAlertModifier: ViewModifier {
    @Binding var alert: Bool
    let alertInfo: AlertInfo?

    func body(content: Content) -> some View {
        content
            .alert(alertInfo?.tittle ?? "Alerta", isPresented: $alert, presenting: alertInfo) { info in
                if let secondButton = info.secondButton {
                    Button {
                        secondButton.action()
                    } label: {
                        Text(secondButton.text)
                    }
                }
                Button(role: .confirm) {
                    info.mainButton.action()
                } label: {
                    Text(info.mainButton.text)
                }
            } message: { info in
                Text(info.message)
            }
    }
}

extension View {
    func alert(alert: Binding<Bool>, alertInfo: AlertInfo?) -> some View {
        modifier(AppAlertModifier(alert: alert, alertInfo: alertInfo))
    }
}
