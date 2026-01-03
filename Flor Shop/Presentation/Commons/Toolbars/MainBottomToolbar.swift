import SwiftUI

struct MainBottomToolbar: ToolbarContent {
    let destination: PushDestination
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            NavigationBasicButton(push: destination, systemImage: "plus")
        }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
    }
}
