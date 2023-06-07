//
//  AgregarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/06/23.
//

import SwiftUI
import CoreData

struct AgregarTopBar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductCoreDataViewModel
    var body: some View {
        HStack{
            Button(action: {
                let _ = print("Se va a presionar Limpiar con nombre")
                productsCoreDataViewModel.setDefaultProduct()
            }) {
                Text("Limpiar")
                    .font(.title)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background(Color("color_hint"))
            .cornerRadius(15.0)
            .font(.title)
            Spacer()
            Button(action: {
                let _ = print("Se va a presionar Guardar con nombre \(productsCoreDataViewModel.temporalProduct.name)")
                if productsCoreDataViewModel.addProduct()
                {
                    print ("Se agrego un producto exitosamente")
                }else{
                    print ("No se pudo agregar correctamente")
                }
            }) {
                Text("Guardar")
                    .font(.title)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal,15)
            .padding(.vertical,10)
            .background(Color("color_secondary"))
            .cornerRadius(15.0)
            .font(.title)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom,8)
        .padding(.horizontal,20)
        .background(Color("color_primary"))
    }
}

struct AgregarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        AgregarTopBar()
    }
}
