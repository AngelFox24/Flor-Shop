//
//  LoadingScreenViewModel.swift
//  TestLoadingScreens
//
//  Created by Angel Curi Laurente on 24/12/2025.
//

import Foundation

struct OverlayModel: Identifiable, Equatable {
    let id: UUID
    let kind: OverlayCases
    let priority: Int
    let insertionIndex: Int
    
    static func == (lhs: OverlayModel, rhs: OverlayModel) -> Bool {
        return lhs.id == rhs.id
    }
}

@MainActor
@Observable
final class OverlayViewModel {
//    private(set)
    var overlays: [OverlayModel] = []
    private var insertionCounter = 0
    
    var visibleOverlay: OverlayModel? {
        overlays.max {
            if $0.priority != $1.priority {
                return $0.priority < $1.priority
            } else {
                return $0.insertionIndex < $1.insertionIndex
            }
        }
    }
}

extension OverlayViewModel {
    func showLoading(
        priority: Int = 10
    ) -> UUID {
        insertionCounter += 1
        let overlay = OverlayModel(
            id: UUID(),
            kind: .loading,
            priority: priority,
            insertionIndex: insertionCounter
        )
        overlays.append(overlay)
        print("Se muestra el loading, count: \(overlays.count), visible es: \(visibleOverlay?.id, default: "")")
        return overlay.id
    }
    
    func endLoading(id: UUID) {
        self.overlays.removeAll { $0.id == id && $0.kind == .loading }
        print("Se termina el loading, count: \(overlays.count)")
    }
    
    private func dismiss(id: UUID) {
        self.overlays.removeAll { $0.id == id }
        print("Se termina el alert id: \(id), count: \(overlays.count)")
    }
    
    func showAlert(
        title: String,
        message: String,
        priority: Int = 100,
        primary: AlertAction
    ) {
        insertionCounter += 1
        let alertId = UUID()
        
        let wrappedPrimary = AlertAction(
            title: primary.title,
            action: { [weak self] in
                primary.action()
                self?.dismiss(id: alertId)
            }
        )
        
        let alert = OverlayModel(
            id: alertId,
            kind: .alert(message: message, primaryAction: wrappedPrimary),
            priority: priority,
            insertionIndex: insertionCounter
        )

        overlays.append(alert)
    }
}
