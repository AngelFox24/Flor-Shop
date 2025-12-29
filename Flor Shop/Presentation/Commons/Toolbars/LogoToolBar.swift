import SwiftUI

struct LogoToolBar: ToolbarContent {
    let action: () -> Void
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: action) {
                Image("logo")
                    .resizable()
                    .frame(width: 32, height: 32)
            }
        }
    }
}
