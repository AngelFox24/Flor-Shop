//
//  CarritoView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI

struct CarritoView: View {
    @State var sumaTotal:Double = 56.50
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack(spacing: 0){
                    CarritoTopBar(totalText: $sumaTotal)
                    ListaCarritoControler()
                }
            }
        }
        .navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CarritoView_Previews: PreviewProvider {
    static var previews: some View {
        CarritoView()
            .environmentObject(ProductoListViewModel())
            //.environmentObject(ProductoCoreDataViewModel())
    }
}

struct ListaCarritoControler: View {
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    var body: some View {
        VStack {
            List(){
                if let detallesCarrito = carritoCoreDataViewModel.carritoCoreData?.carrito_to_detalleCarrito?.allObjects as? [Tb_DetalleCarrito] {
                    ForEach(detallesCarrito) { producto in
                        CarritoProductCardView(nombreProducto: producto.detalleCarrito_to_producto?.nombreProducto ?? "No hay producto", precioUnitarioProducto: producto.detalleCarrito_to_producto?.precioUnitario ?? 0.0, urlProducto: producto.detalleCarrito_to_producto?.url ?? "", cantidadProducto: producto.cantidad, size: 120.0)
                            .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    }
                    .onDelete(perform: deleteProducto)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    func deleteProducto(at offsets: IndexSet) {
            // Convertir los índices a un array
            let indexArray = Array(offsets)
            
            // Eliminar los productos correspondientes de la colección
            for index in indexArray {
                if let detallesCarrito = carritoCoreDataViewModel.carritoCoreData?.carrito_to_detalleCarrito?.allObjects as? [Tb_DetalleCarrito],let producto = detallesCarrito[index].detalleCarrito_to_producto {
                    
                    // Eliminar el producto de la colección
                    carritoCoreDataViewModel.deleteProduct(productoEntity: producto)
                }
            }
        }
    }
