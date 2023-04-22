//
//  BottonBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 21/04/23.
//

import SwiftUI

struct BottonBar: View {
    var vista: String = "BuscarView"
    var body: some View {
            HStack{
                Spacer()
                NavigationLink(destination: AgregarView()) {
                  
                        VStack{
                            Image(systemName: "plus")
                                .foregroundColor(Color(vista == "AgregarView" ? "color_secondary" : "color_background"))
                                .font(.system(size: 25))
                            
                            Text("Agregar")
                                .fontWeight(.regular)
                                .foregroundColor(Color(vista == "AgregarView" ? "color_secondary" : "color_background"))
                        }
                   
                }
                //.navigationBarBackButtonHidden(true)
                Spacer()
                NavigationLink(destination: HomeView()) {
                    
                        VStack{
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color(vista == "BuscarView" ? "color_secondary" : "color_background"))
                                .font(.system(size: 25))
                            
                            Text("Buscar")
                                .fontWeight(.regular)
                                .foregroundColor(Color(vista == "BuscarView" ? "color_secondary" : "color_background"))
                        }
                    
                }
                //.navigationBarBackButtonHidden(true)
                Spacer()
                NavigationLink(destination: AgregarView()) {
                   
                        VStack{
                            Image(systemName: "cart")
                                .foregroundColor(Color(vista == "CarroView" ? "color_secondary" : "color_background"))
                                .font(.system(size: 25))
                                
                            Text("Carro")
                                .fontWeight(.regular)
                                .foregroundColor(Color(vista == "CarroView" ? "color_secondary" : "color_background"))
                        }
                    
                    
                }
                //.navigationBarBackButtonHidden(true)
                Spacer()
            }
            .padding(.top,5)
            .background(Color("color_primary"))
    }
}

struct BottonBar_Previews: PreviewProvider {
    static var previews: some View {
        BottonBar(vista: "CarroView")
    }
}
