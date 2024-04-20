//
//  CustomButtons.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 9/06/23.
//

import SwiftUI

struct CustomButton1: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.custom("Artifika-Regular", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color("color_accent"))
            .cornerRadius(15.0)
    }
}

struct CustomButton2: View {
    let text: String
    var backgroudColor: Color = Color("color_accent")
    var minWidthC: CGFloat = 200
    var body: some View {
        Text(text)
            .font(.custom("Artifika-Regular", size: 20))
            .frame(minWidth: minWidthC)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(backgroudColor)
            .cornerRadius(15.0)
    }
}

struct CustomButton3: View {
    var simbol: String = "chevron.backward"
    var body: some View {
        Image(systemName: simbol)
            .font(.custom("Artifika-Regular", size: 22))
            .foregroundColor(Color("color_accent"))
            .frame(width: 40, height: 40)
            .background(.white)
            .cornerRadius(15)
    }
}

struct CustomButton4: View {
    var simbol: String = "chevron.backward"
    var body: some View {
        Image(systemName: simbol)
            .font(.custom("Artifika-Regular", size: 30))
            .foregroundColor(Color("color_background"))
            .frame(width: 50, height: 50)
            .background(Color("color_accent"))
            .cornerRadius(30)
    }
}
struct CustomButton5: View {
    @State private var isScaled = false
    @Binding var showMenu: Bool
    @AppStorage("hasShownSideBar") private var hasShownSideBar: Bool = false
    var body: some View {
        ZStack(content: {
            Button(action: {
                withAnimation(.spring()){
                    showMenu.toggle()
                    if !hasShownSideBar {
                        hasShownSideBar = true
                    }
                }
            }, label: {
                HStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                }
                .background(Color("colorlaunchbackground"))
                .cornerRadius(10)
                .frame(width: 40, height: 40)
            })
            if !hasShownSideBar {
                VStack(alignment: .center, spacing: 0, content: {
                    Spacer()
                    HStack(content: {
                        Spacer()
                        Color.yellow
                            .frame(width: 7, height: 7)
                            .cornerRadius(5)
                            .padding(.horizontal, 4)
                            .scaleEffect(isScaled ? 1.5 : 1.0)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                    self.isScaled.toggle()
                                }
                            }
                    })
                    .padding(.vertical, 4)
                })
                .frame(width: 40, height: 40)
            }
        })
    }
}

struct CustomButtons_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 5, content: {
            //CustomButton1(text: "Limpiar")
            //CustomButton2(text: "Limpiar")
            //CustomButton3(simbol: "chevron.backward")
            //CustomButton4(simbol: "plus")
            CustomButton5(showMenu: .constant(false))
                .scaleEffect(3.0)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray)
    }
}
