import SwiftUI

struct OverlayContainer<Content: View>: View {
    @Environment(OverlayViewModel.self) var overlayViewModel
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        print("[OverlayContainer] Init.")
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            if let overlay = overlayViewModel.visibleOverlay {
                let _ = print("Hay overlay id: \(overlay.id)")
                ZStack {
                    Color.launchBackground.opacity(0.5).ignoresSafeArea()
                        .allowsHitTesting(true)
                    overlayView(for: overlay)
                }
            }
        }
    }

    @ViewBuilder
    private func overlayView(for overlay: OverlayModel) -> some View {
        switch overlay.kind {
        case .loading:
            LoadingView()
        case .alert(let message, let primaryAction):
            AlertView(message: message, primaryAction: primaryAction)
        case .editAmount(let imageUrl, let confirm, let type, let initialAmount):
            EditAmountView(imageUrl: imageUrl, confirm: confirm, type: type, initialAmount: initialAmount)
        }
    }
}
