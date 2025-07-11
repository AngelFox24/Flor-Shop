//
//  TabButton.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/08/23.
//

import SwiftUI

struct TabButton: View {
    var tab: MenuTab
    @Binding var selectedTab: MenuTab
    @Binding var showMenu: Bool
    //var animation: Namespace.ID
    var body: some View {
        Button(action: {
            selectedTab = tab
            withAnimation(.spring()){
                showMenu.toggle()
            }
        }, label: {
            HStack(spacing: 10, content: {
                Image(systemName: selectedTab == tab ? tab.iconFill : tab.icon)
                    .font(.title2)
                    .frame(minWidth: 50)
                Text(tab.description)
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
                            //.matchedGeometryEffect(id: tab, in: animation)
                    }
                }
            )
        })
    }
}

struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        //@Namespace var animation
        @State var selectedTab: MenuTab = .employeesTab
        @State var isShowMenu: Bool = false
        VStack {
            TabButton(tab: MenuTab.employeesTab, selectedTab: $selectedTab, showMenu: $isShowMenu)
            TabButton(tab: MenuTab.pointOfSaleTab, selectedTab: $selectedTab, showMenu: $isShowMenu)
            TabButton(tab: MenuTab.settingsTab, selectedTab: $selectedTab, showMenu: $isShowMenu)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray)
    }
}
