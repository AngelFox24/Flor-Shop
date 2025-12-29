import SwiftUI

struct MainConfirmationToolbar: ToolbarContent {
    let disabled: Bool
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", systemImage: "checkmark", action: action)
                .disabled(disabled)
        }
    }
}
