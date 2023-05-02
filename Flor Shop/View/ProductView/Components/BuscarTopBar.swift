//
//  BuscarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

import SwiftUI

struct BuscarTopBar: View {
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
                        .disableAutocorrection(true)
                    
                }
                .padding(.all,10)
                .background(Color("color_background"))
                .cornerRadius(35.0)
                .padding(.trailing,8)
                
                Button(action: { }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color("color_primary"))
                        .padding(.horizontal,8)
                        .padding(.vertical,10)
                        .background(Color("color_background"))
                        .cornerRadius(15.0)
                }
                .font(.title)
                //.foregroundColor(Color("color_background"))
            }
            .padding(.horizontal,30)
        }
        .padding(.bottom,10)
        .background(Color("color_primary"))
        
        //.overlay(Color.gray.opacity(0.9))
        //.border(Color.red)
    }
}

struct BuscarTopBar_Previews: PreviewProvider {
    static var previews: some View {
        BuscarTopBar()
    }
}
