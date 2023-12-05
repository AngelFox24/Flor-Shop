//
//  BuscarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct ProductSearchTopBar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    let menuOrders: [PrimaryOrder] = PrimaryOrder.allValues
    let menuFilters: [ProductsFilterAttributes] = ProductsFilterAttributes.allValues
    @Binding var showMenu: Bool
    var body: some View {
        VStack {
            HStack(spacing: 10, content: {
                Button(action: {
                    withAnimation(.spring()){
                        showMenu.toggle()
                    }
                }, label: {
                    HStack {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                    }
                    .background(Color("colorlaunchbackground"))
                    .cornerRadius(10)
                    .frame(width: 40, height: 40)
                })
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("Artifika-Regular", size: 16))
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                    // TODO: Implementar el focus, al pulsar no siempre se abre el teclado
                    TextField("Buscar Producto", text: $productsCoreDataViewModel.searchText)
                        .padding(.vertical, 10)
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color("color_primary"))
                        .submitLabel(.done)
                        .disableAutocorrection(true)
                    Button(action: {
                        productsCoreDataViewModel.searchText = ""
                        //No cambiar muchos atributos Combine
                        //productsCoreDataViewModel.primaryOrder = .nameAsc
                        //productsCoreDataViewModel.filterAttribute = .allProducts
                        //productsCoreDataViewModel.fetchProducts()
                    }, label: {
                        Image(systemName: "x.circle")
                            .foregroundColor(Color("color_accent"))
                            .font(.custom("Artifika-Regular", size: 16))
                            .padding(.vertical, 10)
                            .padding(.trailing, 10)
                    })
                }
                .background(.white)
                .cornerRadius(20.0)
                Menu {
                    Picker("", selection: $productsCoreDataViewModel.primaryOrder) {
                        ForEach(menuOrders, id: \.self) {
                            Text($0.longDescription)
                        }
                    }
                    Divider()
                    Picker("", selection: $productsCoreDataViewModel.filterAttribute) {
                        ForEach(menuFilters, id: \.self) {
                            Text($0.description)
                        }
                    }
                } label: {
                    Button(action: {}, label: {
                        CustomButton3(simbol: "slider.horizontal.3")
                    })
                }
                .onChange(of: productsCoreDataViewModel.primaryOrder, perform: { item in
                    productsCoreDataViewModel.fetchProducts()
                })
                .onChange(of: productsCoreDataViewModel.filterAttribute, perform: { item in
                    productsCoreDataViewModel.fetchProducts()
                })
            })
            .padding(.horizontal, 10)
        }
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
}

struct SearchTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        @State var showMenu: Bool = false
        ProductSearchTopBar(showMenu: $showMenu)
            .environmentObject(dependencies.productsViewModel)
    }
}
