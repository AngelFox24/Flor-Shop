//
//  CarritoView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData

struct CarritoView: View {
    var body: some View {
        NavigationView () {
            ZStack{
                Color("color_background")
                    .ignoresSafeArea()
                VStack(spacing: 0){
                CarritoTopBar()
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
            .environmentObject(CarritoCoreDataViewModel(contenedorBDFlor: NSPersistentContainer(name: "BDFlor")))
    }
}

struct ListaCarritoControler: View {
    @EnvironmentObject var carritoCoreDataViewModel: CarritoCoreDataViewModel
    var body: some View {
        VStack {
            List(){
                if let detallesCarrito = carritoCoreDataViewModel.carritoCoreData?.carrito_to_detalleCarrito?.allObjects as? [Tb_DetalleCarrito] {
                    ForEach(detallesCarrito) { producto in
                        CarritoProductCardView(detalleCarritoEntity:  producto, size: 120.0)
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
