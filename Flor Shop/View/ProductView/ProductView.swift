//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData

struct ProductView: View {
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack(spacing: 0){
                    BuscarTopBar()
                    ListaControler()
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let prdManager = LocalProductManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let repository = ProductRepositoryImpl(manager: prdManager)
        ProductView()
            .environmentObject(ProductCoreDataViewModel(repo: repository))
            .environmentObject(CarritoCoreDataViewModel(contenedorBDFlor: NSPersistentContainer(name: "BDFlor")))
    }
}

struct ListaControler: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    var body: some View {
        
        VStack {
            List(){
                //id: \.self
                ForEach(productsCoreDataViewModel.productsCoreData){ producto in
                    ProductCardView(
                        nombreProducto: producto.name,
                        fechaVencimiento: producto.expirationDate ,
                        cantidadProducto: producto.qty,
                        precioUnitarioProducto: producto.unitPrice,
                        urlProducto: producto.url ,
                        size: 120.0)
                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(action: {
                                agregarProductoACarrito(producto: producto)
                            }) {
                                Image(systemName: "heart.fill")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(action: {
                                editarProducto(producto: producto)
                            }) {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                }
                
            }
            .listStyle(PlainListStyle())
            
        }
    }
    func editarProducto(producto: Product){
        //productsCoreDataViewModel.productsCoreData.
        print("Se edito el producto \(producto.name ?? "No se sabe xd")")
    }
    func agregarProductoACarrito(producto: Product){
        carritoCoreDataViewModel.addProductoToCarrito(productoEntity: producto)
        print("Se agrego el producto al carrito \(producto.name ?? "No se sabe")")
    }
}
