import SwiftUI
    
struct WelcomeView: View {
    var body: some View {
        VStack {
            NavigationStack {
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
                    NavigationLink {
                        LogInView()
                    } label: {
                        CustomButton2(text: "Tengo una cuenta", backgroudColor: Color("color_accent"), minWidthC: 250)
                            .foregroundColor(Color(.black))
                    }
                    NavigationLink {
                        RegistrationView()
                    } label: {
                        CustomButton2(text: "Crear Cuenta", backgroudColor: Color("color_background"), minWidthC: 250)
                            .foregroundColor(Color(.black))
                    }
                }
                Spacer()
            }
        }
        .background(Color.primary)
    }
}

#Preview {
    WelcomeView()
}
