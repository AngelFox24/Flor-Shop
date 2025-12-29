import SwiftUI

struct MainBottomToolbar: ToolbarContent {
    let destination: PushDestination
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            NavigationButton(push: destination) {
                Image(systemName: "plus")
            }
        }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
    }
}
