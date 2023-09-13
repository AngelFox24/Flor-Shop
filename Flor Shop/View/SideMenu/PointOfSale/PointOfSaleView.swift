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
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                if tabSelected == .plus {
                    AgregarView()
                } else if tabSelected == .magnifyingglass {
                    ProductView(selectedTab: $tabSelected, showMenu: $showMenu)
                } else if tabSelected == .cart {
                    CartView(selectedTab: $tabSelected)
                }
            })
            if isKeyboardVisible {
                CustomHideKeyboard()
                    .padding(.bottom, 12)
            } else {
                CustomTabBar(selectedTab: $tabSelected)
            }
        }
        .onAppear {
            productsCoreDataViewModel.lazyFetchProducts()
            carritoCoreDataViewModel.lazyFetchCart()
        }
    }
}
struct PointOfSaleView_Previews: PreviewProvider {
    static var previews: some View {
        @State var isKeyboardVisible: Bool = false
        @State var showMenu: Bool = false
        let prdManager = LocalProductManager(mainContext: CoreDataProvider.shared.viewContext)
        let repository = ProductRepositoryImpl(manager: prdManager)
        PointOfSaleView(isKeyboardVisible: $isKeyboardVisible, showMenu: $showMenu)
            .environmentObject(ProductViewModel(productRepository: repository))
            .environmentObject(VersionCheck())
    }
}
