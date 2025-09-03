import SwiftUI
    
struct WelcomeView: View {
    var body: some View {
        VStack {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .background(Color.launchBackground)
                .cornerRadius(30)
                .frame(width: 200, height: 200)
            Spacer()
            VStack(spacing: 20) {
                Text("Hola! Bienvenido a Flor Shop")
                    .font(.custom("Artifika-Regular", size: 30))
                Text("Administra tu negocio fácilmente, Flor Shop te ayudará a gestionar tus recursos y ventas.")
                    .font(.custom("Artifika-Regular", size: 20))
                    .padding(.horizontal, 15)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            VStack(spacing: 30) {
                Button(action: {
//                    router.navigateTo(.loginView)
                }, label: {
                    CustomButton2(text: "Tengo una cuenta", backgroudColor: Color("color_accent"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
                Button(action: {
//                    router.navigateTo(.registrationView)
                }, label: {
                    CustomButton2(text: "Crear Cuenta", backgroudColor: Color("color_background"), minWidthC: 250)
                        .foregroundColor(Color(.black))
                })
            }
            Spacer()
        }
        .background(Color("color_primary"))
    }
}

#Preview {
    WelcomeView()
}
