//
//  MenuView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct MenuView: View {
    @State private var tabSelected: Tab = .magnifyingglass
    @State private var isKeyboardVisible: Bool = false
    @EnvironmentObject var versionCheck: VersionCheck
    var body: some View {
        VStack(spacing: 0) {
            switch versionCheck.versionIsOk {
            case .loading:
                LaunchScreenView()
            case .lockVersion:
                LockScreenView()
            case .versionOk:
                if tabSelected == .plus {
                    AgregarView()
                } else if tabSelected == .magnifyingglass {
                    ProductView(selectedTab: $tabSelected)
                } else if tabSelected == .cart {
                    CartView(selectedTab: $tabSelected)
                }
                if isKeyboardVisible {
                    CustomHideKeyboard()
                } else {
                    CustomTabBar(selectedTab: $tabSelected)
                }
            case .unowned:
                LockScreenView()
            }
        }
        .onAppear {
            versionCheck.checkAppVersion()
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
        let prdManager = LocalProductManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let repository = ProductRepositoryImpl(manager: prdManager)
        MenuView()
            .environmentObject(ProductViewModel(productRepository: repository))
            .environmentObject(VersionCheck())
    }
}
