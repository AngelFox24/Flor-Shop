//
//  TestView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/23.
//

import SwiftUI

struct OnboardingView: View {
    @State private var indexito = 0
    var onAction: () -> Void
    var indexFin = onboardItems.count
    var body: some View {
        VStack(spacing: 0) {
            // Texto Informativo
            ZStack {
                ForEach(0 ..< indexFin) { index in
                    VStack(spacing: 0) {
                        Text(onboardItems[index].title)
                            .font(.custom("Artifika-Regular", size: 28))
                            .foregroundColor(Color("color_accent"))
                            .multilineTextAlignment(.center)
                        Text(onboardItems[index].subtitle)
                            .font(.custom("Artifika-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .foregroundColor(Color("color_accent"))
                    }
                    .opacity(index == indexito ? 1 : 0)
                    .offset(CGSize(width: 0, height: index == indexito ? 0 : -100))
                    .animation(.easeInOut, value: index == indexito)
                }
            }
            // Imagen
            TabView(selection: $indexito) {
                ForEach(0..<indexFin) { index in
                    Image(onboardItems[index].imageText)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            // Puntitos
            HStack(spacing: 8) {
                ForEach(0..<indexFin) { index in
                    Color("color_accent")
                        .opacity(index == indexito ? 1 : 0.5)
                        .frame(width: index == indexito ? 14 : 10, height: index == indexito ? 14 : 10)
                        .cornerRadius(6)
                        .animation(.easeInOut(duration: 0.4), value: index == indexito)
                }
            }
            // Boton para terminar
            Button(action: {
                if indexito == onboardItems.count - 1 {
                    onAction()
                }
            }, label: {
                CustomButton1(text: "Comenzar")
                    .opacity(indexito == onboardItems.count - 1 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: indexito == onboardItems.count - 1 )
            })
            .padding(.top, 25)
        }
        .padding()
        .background(Color("color_secondary"))
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onAction: {
            print("ss")
        })
    }
}
