//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData

struct ProductView: View {
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0){
            BuscarTopBar()
            ListaControler(selectedTab: $selectedTab)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let productManager = LocalProductManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let productRepository = ProductRepositoryImpl(manager: productManager)
        
        let carManager = LocalCarManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        ProductView(selectedTab: .constant(.magnifyingglass))
            .environmentObject(ProductCoreDataViewModel(productRepository: productRepository))
            .environmentObject(CarritoCoreDataViewModel(carRepository: carRepository))
    }
}

struct ListaControler: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0) {
            List(){
                ForEach(productsCoreDataViewModel.productsCoreData){ producto in
                    ProductCardView(
                        nombreProducto: producto.name,
                        fechaVencimiento: producto.expirationDate ,
                        cantidadProducto: producto.qty,
                        precioUnitarioProducto: producto.unitPrice,
                        urlProducto: producto.url ,
                        size: 120.0)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(action: {
                            agregarProductoACarrito(producto: producto)
                        }) {
                            Image(systemName: "cart")
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(action: {
                            editarProducto(producto: producto)
                            selectedTab = .plus
                        }) {
                            Image(systemName: "pencil")
                        }
                        .tint(.red)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    func editarProducto(producto: Product){
        productsCoreDataViewModel.editProduct(product: producto)
        print("Se esta editando el producto \(producto.name)")
    }
    func agregarProductoACarrito(producto: Product){
        carritoCoreDataViewModel.addProductoToCarrito(product: producto)
        print("Se agrego el producto al carrito \(producto.name)")
    }
}
