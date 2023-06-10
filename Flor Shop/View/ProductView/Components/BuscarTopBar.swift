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
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("text_font_1", size: 16))
                        .padding(.vertical,10)
                        .padding(.leading,10)
                    //TODO: Implementar el focus, al pulsar no siempre se abre el teclado
                    TextField("Buscar Producto",text: $seach)
                        .padding(.vertical,10)
                        .font(.custom("text_font_1", size: 16))
                        .foregroundColor(Color("color_primary"))
                        .submitLabel(.search)
                        .onSubmit {
                            filtrarProductos()
                        }
                        .disableAutocorrection(true)
                }
                .background(.white)
                .cornerRadius(20.0)
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
                            .font(.custom("text_font_1", size: 22))
                            .foregroundColor(Color("color_accent"))
                    }
                    .padding(.horizontal,8)
                    .padding(.vertical,10)
                    .background(.white)
                    .cornerRadius(15.0)
                }
            }
            .padding(.horizontal,30)
        }
        .padding(.bottom,9)
        .background(Color("color_primary"))
        .onAppear{
            let _ = print ("Aparecio")
        }
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
