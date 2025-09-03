import SwiftUI

struct SideMenuView: View {
    @Binding var menuTab: TabDestination?
    let showMenu: () -> Void
    let navTabsIter: [TabDestination] = TabDestination.navTabs()
    var body: some View {
            ZStack {
                Color("color_accent")
                    .ignoresSafeArea()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 15, content: {
                        VStack(alignment: .leading, spacing: 15, content: {
                            Image("logo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .background(Color.launchBackground)
                                .frame(width: 80, height: 80)
                                .cornerRadius(15)
                                .padding(.top, 50)
                            VStack(alignment: .leading, spacing: 6, content: {
                                Text("Flor Shop")
                                    .font(.custom("Artifika-Regular", size: 30))
                                    .foregroundColor(Color(.white))
                                /*
                                Text("View Profile")
                                    .font(.custom("Artifika-Regular", size: 15))
                                    .foregroundColor(Color(.white))
                                    .opacity(0.7)
                                 */
                            })
                        })
                        .padding(.leading, 15)
                        VStack(alignment: .leading, spacing: 15, content: {
                            ForEach(navTabsIter, id: \.self) {tab in
                                TabButton(tab: tab, selectedTab: $menuTab, showMenu: {
                                    showMenu()
                                })
                            }
                        })
                        Spacer()
                        VStack(alignment: .leading, spacing: 5, content: {
                            //TabButton(tab: MenuTab.logOut, selectedTab: $selectedTab, showMenu: $showMenu)
                            Text("App Version 2.0.2")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .opacity(0.6)
                                .padding(.leading, 15)
                                .padding(.bottom, 10)
                        })
                    })
                    Spacer()
                }
            }
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        @State var menuTab: TabDestination? = .pointOfSale
        SideMenuView(menuTab: $menuTab, showMenu: {})
    }
}
