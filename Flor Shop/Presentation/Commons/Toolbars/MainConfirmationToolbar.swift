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

struct MainConfirmationAsyncToolbar: ToolbarContent {
    let disabled: Bool
    let isLoading: Bool
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm, action: action) {
                Image(systemName: isLoading ? "progress.indicator" : "checkmark")
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(
                        .rotate.byLayer,
                        options: isLoading ? .repeat(.continuous) : .default,
                        value: isLoading
                    )
            }
            .disabled(disabled || isLoading)
        }
    }
}
