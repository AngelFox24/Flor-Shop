import SwiftUI

struct TabButton: View {
    var tab: TabDestination
    @Binding var selectedTab: TabDestination
    let showMenu: () -> Void
    var body: some View {
        Button {
            selectedTab = tab
            withAnimation(.spring()){
                showMenu()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selectedTab == tab ? tab.iconFill : tab.icon)
                    .font(.title2)
                    .frame(minWidth: 50)
                Text(tab.description)
            }
            .foregroundColor(selectedTab == tab ? Color.accentColor : Color(.white))
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(maxWidth: getRect().width - 200, alignment: .leading)
            .background(
                ZStack {
                    if selectedTab == tab {
                        Color.white
                            .opacity(selectedTab == tab ? 1 : 0)
                            .clipShape(CustomCorners(corners: [.topRight, .bottomRight], radius: 15))
                    }
                }
            )
        }
    }
}

struct LogoutButtonView: View {
    var body: some View {
            HStack(spacing: 10) {
                Image(systemName: "iphone.and.arrow.right.outward")
                    .font(.title2)
                    .frame(minWidth: 50)
                Text("Cerrar sesión")
            }
            .foregroundColor(Color(.white))
            .padding(.vertical, 12)
            .padding(.horizontal, 10)
            .frame(maxWidth: getRect().width - 200, alignment: .leading)
    }
}

#Preview {
    @Previewable @State var stab: TabDestination = .pointOfSale
    var tab: TabDestination = .employees
    TabButton(tab: tab, selectedTab: $stab, showMenu: {})
}
