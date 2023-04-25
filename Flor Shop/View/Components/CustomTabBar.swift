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
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    VStack {
                        Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                            .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                            .foregroundColor(tab == selectedTab ? Color("color_secondary") : .gray)
                            .font(.system(size: 20))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    selectedTab = tab
                                }
                            }
                        Text(getTabText(for: tab))
                            .fontWeight(.regular)
                            .foregroundColor(tab == selectedTab ? Color("color_secondary") : .gray)
                    }
                    Spacer()
                }
            }
            .frame(width: nil, height: 60)
            .background(Color("color_primary"))
            //.cornerRadius(20)
            //.padding()
            }
    }
}
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.cart))
    }
}
