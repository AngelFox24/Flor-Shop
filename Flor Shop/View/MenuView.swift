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
    var body: some View {
        VStack(spacing: 0){
            if tabSelected == .plus {
                AgregarView()
            }else if tabSelected == .magnifyingglass {
                ProductView(selectedTab: $tabSelected)
            }else if tabSelected == .cart {
                CarritoView()
            }
            if isKeyboardVisible{
                CustomHideKeyboard()
            }else{
                CustomTabBar(selectedTab: $tabSelected)
            }
        }
        .onAppear {
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
        let prdManager = LocalProductManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let repository = ProductRepositoryImpl(manager: prdManager)
        MenuView()
            .environmentObject(ProductCoreDataViewModel(productRepository: repository))
    }
}
