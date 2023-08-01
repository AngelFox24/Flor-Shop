//
//  BuscarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct SearchTopBar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @State private var selectedItem: PrimaryOrder?
    let menuItems: [PrimaryOrder] = PrimaryOrder.allValues
    @State private var seach: String = ""
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("Artifika-Regular", size: 16))
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                    // TODO: Implementar el focus, al pulsar no siempre se abre el teclado
                    TextField("Buscar Producto", text: $seach)
                        .padding(.vertical, 10)
                        .font(.custom("Artifika-Regular", size: 16))
                        .foregroundColor(Color("color_primary"))
                        .submitLabel(.search)
                        .onSubmit {
                            filtrarProductos()
                        }
                        .disableAutocorrection(true)
                    Button(action: {
                        seach = ""
                        setPrimaryOrder(order: .nameAsc)
                        filtrarProductos()
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
                .padding(.trailing, 8)
                Menu {
                    ForEach(menuItems, id: \.self) { item in
                        Button(action: {
                            selectedItem = item
                            setPrimaryOrder(order: item)
                        }, label: {
                            HStack {
                                Text(item.longDescription)
                            }
                        })
                    }
                } label: {
                    Button(action: {}, label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.custom("text_font_1", size: 22))
                            .foregroundColor(Color("color_accent"))
                    })
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(15.0)
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
    func filtrarProductos() {
        productsCoreDataViewModel.filterProducts(word: seach)
    }
    func setPrimaryOrder(order: PrimaryOrder) {
        productsCoreDataViewModel.setPrimaryFilter(filter: order, word: seach)
    }
}

struct SearchTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let productManager = LocalProductManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let productRepository = ProductRepositoryImpl(manager: productManager)
        SearchTopBar()
            .environmentObject(ProductViewModel(productRepository: productRepository))
    }
}
