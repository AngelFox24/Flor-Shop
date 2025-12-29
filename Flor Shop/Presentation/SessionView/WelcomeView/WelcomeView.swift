import SwiftUI
import FlorShopDTOs
import AVFoundation

enum SessionRoutes: Hashable {
    case companySelection(provider: AuthProvider, token: String)
    case subsidiarySelection(companyCic: String)
}

struct WelcomeView: View {
    @State private var path: [SessionRoutes] = []
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.primary
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Spacer()
                        Text("Iniciar Sesión")
                            .font(.custom("Artifika-Regular", size: 25))
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    ScrollView {
                        VStack(spacing: 30) {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .background(Color.launchBackground)
                                .cornerRadius(30)
                                .frame(width: 200, height: 200)
                            VStack(spacing: 20) {
                                Text("Hola! Bienvenido a Flor Shop")
                                    .font(.custom("Artifika-Regular", size: 30))
                                Text("Administra tu negocio fácilmente, Flor Shop te ayudará a gestionar tus recursos y ventas.")
                                    .font(.custom("Artifika-Regular", size: 20))
                                    .padding(.horizontal, 15)
                            }
                            VStack(spacing: 30) {
                                GoogleSingInButton(path: $path)
                                Button {
                                    let session = SessionManager(sessionRepository: SessionRepositoryImpl.mock())
                                    Task {
                                        let companies = try? await session.login(provider: .google, token: "")
                                        await MainActor.run {
                                            self.path.append(.companySelection(provider: .google, token: ""))
                                        }
                                        print("COmpanies count: \(companies?.count ?? 0)")
                                        print("Path count: \(self.path)")
                                    }
                                } label: {
                                    CustomButton2(text: "Login mock", backgroudColor: Color("color_secondary"), minWidthC: 250)
                                        .foregroundColor(Color(.black))
                                }
                            }
                            .padding(.top, 30)
                            Spacer()
                        }
                        .padding(.top, 30)
                    }
                    .padding(.top, 1)//Resuelve el problema del desvanecimiento en el navigation back button
                }
            }
            .navigationDestination(for: SessionRoutes.self) { route in
                switch route {
                case .companySelection(let provider, let token):
                    CompanySelectionView(provider: provider, token: token, path: $path)
                case .subsidiarySelection(let companyCic):
                    SubsidiarySelectionView(companyCic: companyCic, path: $path)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var sessionManager = SessionManager(sessionRepository: SessionRepositoryImpl.mock())
    WelcomeView()
        .environment(sessionManager)
}
