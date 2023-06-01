//
//  BuscarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct BuscarTopBar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    @State private var seach:String = ""
    var body: some View {
        
        VStack {
            HStack{
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("color_primary"))
                        .font(.system(size: 25))
                    TextField("Buscar Producto",text: $seach)
                        .foregroundColor(Color("color_primary"))
                        .submitLabel(.search)
                        .onSubmit {
                            filtrarProductos()
                        }
                        .disableAutocorrection(true)
                }
                .padding(.all,10)
                .background(Color("color_background"))
                .cornerRadius(35.0)
                .padding(.trailing,8)
                Menu {
                    Button(){
                        setPrimaryOrder(order: .NameAsc)
                    } label: {
                        Text("Nombre")
                    }
                    Button(){
                        setPrimaryOrder(order: .QuantityAsc)
                    } label: {
                        Text("Sin Stock")
                    }
                    Button(){
                        setPrimaryOrder(order: .QuantityDesc)
                    } label: {
                        Text("Cantidad Mayor")
                    }
                    Button(){
                        setPrimaryOrder(order: .PriceDesc)
                    } label: {
                        Text("Precio Mayor")
                    }
                    Button(){
                        setPrimaryOrder(order: .PriceAsc)
                    } label: {
                        Text("Precio Menor")
                    }
                }label: {
                    Button(action: { }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color("color_primary"))
                            .padding(.horizontal,8)
                            .padding(.vertical,10)
                            .background(Color("color_background"))
                            .cornerRadius(15.0)
                    }
                    .font(.title)
                }
            }
            .padding(.horizontal,30)
        }
        .padding(.bottom,10)
        .background(Color("color_primary"))
    }
    func filtrarProductos(){
        productsCoreDataViewModel.filterProducts(word: seach)
    }
    func setPrimaryOrder(order: PrimaryOrder){
        productsCoreDataViewModel.setPrimaryFilter(filter: order, word: seach)
    }
}

struct BuscarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let productManager = LocalProductManager(contenedorBDFlor: CoreDataProvider.shared.persistContainer)
        let productRepository = ProductRepositoryImpl(manager: productManager)
        BuscarTopBar()
            .environmentObject(ProductCoreDataViewModel(productRepository: productRepository))
    }
}
