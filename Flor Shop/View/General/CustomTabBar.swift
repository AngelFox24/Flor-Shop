//
//  CustomTabBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case plus
    case magnifyingglass
    case cart
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    private var fillImage: String {
        if (selectedTab==Tab.cart){
            return selectedTab.rawValue + ".fill"
        }else{
            return selectedTab.rawValue
        }
    }
    func getTabText(for tab: Tab) -> String {
        switch tab {
        case .plus:
            return "Agregar"
        case .magnifyingglass:
            return "Buscar"
        case .cart:
            return "Carro"
        }
    }
    var body: some View {
        VStack {
            HStack() {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                                    .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                                    .foregroundColor(tab == selectedTab ? Color("color_secondary") : Color("color_background"))
                                    .font(.system(size: 20))
                                
                                Text(getTabText(for: tab))
                                    .fontWeight(.regular)
                                    .foregroundColor(tab == selectedTab ? Color("color_secondary") : Color("color_background"))
                            }
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .frame(width: nil, height: 60)
            .background(Color("color_primary"))
        }
    }
}
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.cart))
    }
}
