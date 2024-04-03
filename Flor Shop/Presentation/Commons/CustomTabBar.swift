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
        if selectedTab==Tab.cart {
            return selectedTab.rawValue + ".fill"
        } else {
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
        ZStack {
            VStack {
                //Spacer()
                HStack {
                    ForEach(Tab.allCases, id: \.rawValue) { tab in
                        VStack {
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                                        .scaleEffect(tab == selectedTab ? 1.25 : 1.0)
                                        .foregroundColor(tab == selectedTab ? Color("color_accent") : .white)
                                        .font(.custom("Artifika-Regular", size: 24))
                                    Text(getTabText(for: tab))
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
        }
    }
}
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.cart))
    }
}
