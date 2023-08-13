//
//  BuscarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct SearchTopBar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @State private var selectedOrder: PrimaryOrder = PrimaryOrder.nameAsc
    @State private var selectedFilter: ProductsFilterAttributes = ProductsFilterAttributes.allProducts
    let menuOrders: [PrimaryOrder] = PrimaryOrder.allValues
    let menuFilters: [ProductsFilterAttributes] = ProductsFilterAttributes.allValues
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
                            filtrarProductos(filterWord: seach)
                        }
                        .disableAutocorrection(true)
                    Button(action: {
                        seach = ""
                        selectedOrder = .nameAsc
                        selectedFilter = .allProducts
                        setOrder(order: selectedOrder)
                        setFilter(filter: selectedFilter)
                        filtrarProductos(filterWord: seach)
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
                    Picker("", selection: $selectedOrder) {
                        ForEach(menuOrders, id: \.self) {
                            Text($0.longDescription)
                        }
                    }
                    Divider()
                    Picker("", selection: $selectedFilter) {
                        ForEach(menuFilters, id: \.self) {
                            Text($0.description)
                        }
                    }
                } label: {
                    Button(action: {}, label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 22))
                            .foregroundColor(Color("color_accent"))
                    })
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(15.0)
                }
                .onChange(of: selectedOrder, perform: { item in
                    setOrder(order: item)
                    filtrarProductos(filterWord: seach)
                })
                .onChange(of: selectedFilter, perform: { item in
                    setFilter(filter: item)
                    filtrarProductos(filterWord: seach)
                })
            }
            .padding(.horizontal, 30)
        }
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
    func setOrder(order: PrimaryOrder) {
        productsCoreDataViewModel.setOrder(order: order)
    }
    func setFilter(filter: ProductsFilterAttributes) {
        productsCoreDataViewModel.setFilter(filter: filter)
        print("Se presiono setFilter")
    }
    func filtrarProductos(filterWord: String) {
        print("Se presiono buscarProductos")
        productsCoreDataViewModel.filterProducts(word: filterWord)
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
