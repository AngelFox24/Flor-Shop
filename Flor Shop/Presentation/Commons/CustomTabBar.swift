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
    var description: String {
        switch self {
        case .plus:
            "Agregar"
        case .magnifyingglass:
            "Buscar"
        case .cart:
            "Carro"
        }
    }
    var normal: String {
        switch self {
        case .plus:
            "plus"
        case .magnifyingglass:
            "magnifyingglass"
        case .cart:
            "cart"
        }
    }
    var filled: String {
        switch self {
        case .plus:
            "plus"
        case .magnifyingglass:
            "magnifyingglass"
        case .cart:
            "cart.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                Image(systemName: selectedTab == tab ? tab.filled : tab.normal)
                                    .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                                    .foregroundColor(tab == selectedTab ? Color("color_accent") : .white)
                                    .font(.custom("Artifika-Regular", size: 24))
                                Text(tab.description)
                                    .font(.custom("Artifika-Regular", size: 16))
                                    .foregroundColor(tab == selectedTab ? Color("color_accent") : .white)
                            }
                            .padding(.top, 8)
                            //.padding(.bottom, 60)
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
            .background(Color("color_primary"))
            .frame(width: nil, height: 50)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar_Previews: View {
    @State var selectedTab: Tab = .cart
    var body: some View {
        CustomTabBar(selectedTab: $selectedTab)
    }
}

#Preview {
    CustomTabBar_Previews()
}
