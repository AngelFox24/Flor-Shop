import SwiftUI

struct TabButton: View {
    var tab: TabDestination
    @Binding var selectedTab: TabDestination?
    let showMenu: () -> Void
    var body: some View {
        Button(action: {
            selectedTab = tab
            withAnimation(.spring()){
                showMenu()
            }
        }, label: {
            HStack(spacing: 10, content: {
                //TODO: Add image
//                Image(systemName: selectedTab == tab ? tab.iconFill : tab.icon)
//                    .font(.title2)
//                    .frame(minWidth: 50)
//                Text(tab.description)
                Text(tab.rawValue)
            })
            .foregroundColor(selectedTab == tab ? Color("color_accent") : Color(.white))
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
        })
    }
}

struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        //@Namespace var animation
        @State var selectedTab: TabDestination? = .pointOfSale
        VStack {
            TabButton(tab: TabDestination.pointOfSale, selectedTab: $selectedTab, showMenu: {})
            TabButton(tab: TabDestination.customers, selectedTab: $selectedTab, showMenu: {})
            TabButton(tab: TabDestination.employees, selectedTab: $selectedTab, showMenu: {})
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
    }
}
