import Foundation
import FlorShopDTOs

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
        priority: Int = 10,
        origin: String
    ) -> UUID {
        insertionCounter += 1
        let overlay = OverlayModel(
            id: UUID(),
            kind: .loading,
            priority: priority,
            insertionIndex: insertionCounter
        )
        overlays.append(overlay)
        print("[OverlayViewModel] Se muestra el loading, count: \(overlays.count), visible es: \(visibleOverlay?.id, default: ""), origin: \(origin)")
        return overlay.id
    }
    
    func endLoading(
        id: UUID,
        origin: String
    ) {
        self.overlays.removeAll { $0.id == id && $0.kind == .loading }
        print("[OverlayViewModel] Se termina el loading, count: \(overlays.count), origin: \(origin)")
    }
    
    private func dismiss(id: UUID) {
        self.overlays.removeAll { $0.id == id }
        print("[OverlayViewModel] Se termina el alert id: \(id), count: \(overlays.count)")
    }
    
    func showAlert(
        title: String,
        message: String,
        priority: Int = 100,
        primary: ConfirmAction
    ) {
        insertionCounter += 1
        let alertId = UUID()
        
        let wrappedPrimary = ConfirmAction(
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
    
    func showEditAmountView(
        imageUrl: String?,
        confirm: EditAction,
        type: UnitType,
        initialAmount: Int,
        priority: Int = 100
    ) {
        insertionCounter += 1
        let alertId = UUID()
        
        let wrappedPrimary = EditAction(
            title: confirm.title,
            action: { [weak self] amount in
                confirm.action(amount)
                self?.dismiss(id: alertId)
            }
        )
        
        let alert = OverlayModel(
            id: alertId,
            kind: .editAmount(imageUrl: imageUrl, confirm: wrappedPrimary, type: type, initialAmount: initialAmount),
            priority: priority,
            insertionIndex: insertionCounter
        )

        overlays.append(alert)
    }
}
