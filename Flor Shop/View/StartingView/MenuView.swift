//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/08/23.
//

import SwiftUI

struct MenuView: View {
    @State private var selectedTab: MenuTab = .pointOfSaleTab
    @State private var showMenu: Bool = false
    @State private var isKeyboardVisible: Bool = false
    @State private var tabSelected: Tab = .magnifyingglass
    var body: some View {
        ZStack {
            SideMenuView(selectedTab: $selectedTab, showMenu: $showMenu)
            ZStack {
                Color(.white)
                    .opacity(0.5)
                    .cornerRadius(showMenu ? 35 : 0)
                    .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                    .offset(x: showMenu ? -25 : 0)
                    .padding(.vertical, 30)
                Color(.white)
                    .opacity(0.4)
                    .cornerRadius(showMenu ? 35 : 0)
                    .shadow(color: Color.black.opacity(0.07), radius: 5, x: -5, y: 0)
                    .offset(x: showMenu ? -50 : 0)
                    .padding(.vertical, 60)
                PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
                    //.cornerRadius(showMenu ? 35 : 0)
                    //.ignoresSafeArea()
            }
            .scaleEffect(showMenu ? 0.84 : 1)
            .offset(x: showMenu ? getRect().width - 120 : 0)
            //.ignoresSafeArea()
        }
        .onAppear {
            // checkForPermission()
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = true
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = false
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        let prdManager = LocalProductManager(mainContext: CoreDataProvider.shared.viewContext)
        let repository = ProductRepositoryImpl(manager: prdManager)
        MenuView()
            .environmentObject(ProductViewModel(productRepository: repository))
            .environmentObject(VersionCheck())
    }
}
