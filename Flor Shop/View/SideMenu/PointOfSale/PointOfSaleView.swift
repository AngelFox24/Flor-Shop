//
//  PointOfSaleView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/08/23.
//

import SwiftUI

struct PointOfSaleView: View {
    @State var tabSelected: Tab = .magnifyingglass
    @Binding var isKeyboardVisible: Bool
    @Binding var showMenu: Bool
    var body: some View {
        VStack(spacing: 0, content: {
            if tabSelected == .plus {
                AgregarView()
            } else if tabSelected == .magnifyingglass {
                ProductView(selectedTab: $tabSelected, showMenu: $showMenu)
            } else if tabSelected == .cart {
                CartView(selectedTab: $tabSelected)
            }
            if isKeyboardVisible {
                CustomHideKeyboard()
            } else {
                CustomTabBar(selectedTab: $tabSelected)
            }
        })
        .cornerRadius(showMenu ? 35 : 0)
    }
}
/*
struct PointOfSaleView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isKeyboardVisible: Bool = false
        @State var showMenu: Bool = false
        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
    }
}
*/
