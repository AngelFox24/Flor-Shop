//
//  OverlayContainer.swift
//  TestLoadingScreens
//
//  Created by Angel Curi Laurente on 24/12/2025.
//

import SwiftUI

struct OverlayContainer<Content: View>: View {
    @Environment(OverlayViewModel.self) var overlayViewModel
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
            if let overlay = overlayViewModel.visibleOverlay {
                let _ = print("Hay overlay id: \(overlay.id)")
                Color.gray.opacity(0.3).ignoresSafeArea()
                overlayView(for: overlay)
            }
        }
    }

    @ViewBuilder
    private func overlayView(for overlay: OverlayModel) -> some View {
        switch overlay.kind {

        case .loading:
            LoadingView()

//        case .toast(let message):
//            ToastView(message: message)
//
        case .alert(let message, let primaryAction):
            AlertView(message: message, primaryAction: primaryAction)
//            AlertView(
//                title: data.title,
//                message: data.message,
//                primary: data.primary,
//                secondary: data.secondary
//            )
        }
    }
}
