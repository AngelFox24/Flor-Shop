//
//  AgregarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/06/23.
//

import SwiftUI
import CoreData

struct AgregarTopBar: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @Binding var editedFields: AgregarViewModel
    var body: some View {
        HStack {
            // El boton de Limpiar tiene un bug por lo que no pasa a prod
            /*
             Button(action: {
             editedFields.resetValuesFields()
             productsCoreDataViewModel.setDefaultProduct()
             }) {
             CustomButton2(text: "Limpiar")
             }
             */
            Spacer()
            Button(action: {
                if productsCoreDataViewModel.addProduct() {
                    print("Se agrego un producto exitosamente")
                    carritoCoreDataViewModel.updateCartTotal()
                    editedFields.resetValuesFields()
                } else {
                    print("No se pudo agregar correctamente")
                }
            }, label: {
                CustomButton1(text: "Guardar")
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 40)
        .background(Color("color_primary"))
    }
}

struct AgregarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        AgregarTopBar(editedFields: .constant(AgregarViewModel()))
    }
}
