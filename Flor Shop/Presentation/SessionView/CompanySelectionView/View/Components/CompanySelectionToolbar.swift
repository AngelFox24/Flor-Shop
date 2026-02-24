import SwiftUI

struct CompanySelectionToolbar: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button("Done", systemImage: "plus", action: action)
        }
        ToolbarSpacer(placement: .bottomBar)
    }
}
