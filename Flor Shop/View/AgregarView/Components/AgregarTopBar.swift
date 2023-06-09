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
                
                CustomButton2(text: "Limpiar")
            }
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
                CustomButton1(text: "Guardar")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom,8)
        .padding(.horizontal,40)
        .background(Color("color_primary"))
    }
}

struct AgregarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        AgregarTopBar()
    }
}
