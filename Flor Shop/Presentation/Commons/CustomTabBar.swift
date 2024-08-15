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
//        ZStack {
        TabView(selection: $selectedTab) {
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
                        .tag(tab)
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
        .border(Color.red)
//        }
    }
}

struct ContentView23: View {
    @Binding var selectedTab: Tab

    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Primera pestaña")
                    .font(.title)
            }
            .tabItem {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("Primera pestaña")
                        .font(.title)
                }
                .background(Color.red)
//                Label("Agregar", systemImage: "plus")
            }
            .tag(Tab.plus)

            VStack {
                Image(systemName: "house")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Segunda pestaña")
                    .font(.title)
            }
            .tabItem {
                Label("Buscar", systemImage: "magnifyingglass")
            }
            .tag(Tab.magnifyingglass)

            VStack {
                Image(systemName: "gear")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Tercera pestaña")
                    .font(.title)
            }
            .tabItem {
                Label("Cart", systemImage: "cart")
            }
            .tag(Tab.cart)
        }
    }
}
struct CustomTabBar_Previews: View {
    @State var selectedTab: Tab = .cart
    var body: some View {
        ContentView23(selectedTab: $selectedTab)
    }
}

#Preview {
    CustomTabBar_Previews()
}
