import SwiftUI

struct RegistrationToolbar: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", systemImage: "checkmark", action: action)
        }
    }
}
