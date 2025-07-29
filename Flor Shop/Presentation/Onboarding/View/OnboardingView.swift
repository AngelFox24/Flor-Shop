import SwiftUI

struct OnboardingView: View {
    @State private var selectedItemId: UUID?
    @AppStorage("hasShownOnboarding") var hasShownOnboarding: Bool = false
    @State var onboardinItems: [OnboardItem] = []
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ForEach(onboardinItems) { item in
                    VStack(spacing: 0) {
                        Text(item.title)
                            .font(.custom("Artifika-Regular", size: 28))
                            .foregroundColor(Color("color_accent"))
                            .multilineTextAlignment(.center)
                        Text(item.subtitle)
                            .font(.custom("Artifika-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                            .foregroundColor(Color("color_accent"))
                    }
                    .opacity(isItemSelected(item.id, to: selectedItemId) ? 1 : 0)
                    .offset(CGSize(width: 0, height: isItemSelected(item.id, to: selectedItemId) ? 0 : -100))
                    .animation(.easeInOut, value: isItemSelected(item.id, to: selectedItemId))
                }
            }
            // Imagen
            TabView(selection: $selectedItemId) {
                ForEach(onboardinItems) { item in
                    Image(item.imageText)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            // Puntitos
            HStack(spacing: 8) {
                ForEach(onboardinItems) { item in
                    Color("color_accent")
                        .opacity(isItemSelected(item.id, to: selectedItemId) ? 1 : 0.5)
                        .frame(width: isItemSelected(item.id, to: selectedItemId) ? 14 : 10, height: isItemSelected(item.id, to: selectedItemId) ? 14 : 10)
                        .cornerRadius(6)
                        .animation(.easeInOut(duration: 0.4), value: isItemSelected(item.id, to: selectedItemId))
                }
            }
            // Boton para terminar
            Button(action: {
                if isItemSelected(selectedItemId, to: onboardinItems.last?.id) {
                    hasShownOnboarding = true
                }
            }, label: {
                CustomButton1(text: "Comenzar")
                    .opacity(isItemSelected(selectedItemId, to: onboardinItems.last?.id) ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: isItemSelected(selectedItemId, to: onboardinItems.last?.id))
            })
            .padding(.top, 25)
        }
        .padding()
        .background(Color("color_secondary"))
        .onAppear {
            onboardinItems = getOnboardItems()
            selectedItemId = onboardinItems.first?.id
        }
    }
    func isItemSelected(_ itemId: UUID?, to otherItemId: UUID?) -> Bool {
        guard let itemId = itemId,
              let otherItemId = otherItemId else { return false }
        return itemId == otherItemId
    }
    func getOnboardItems() -> [OnboardItem] {
        let onboardItems: [OnboardItem] = [
            OnboardItem(id: UUID(), title: "Para agregar un Producto", subtitle: "Rellenamos el nombre del producto y luego pulsamos en Buscar Imagen", imageText: "View1"),
            OnboardItem(id: UUID(), title: "Elegimos una imagen", subtitle: "mantenemos pulsado en la imagen y copiamos", imageText: "View2"),
            OnboardItem(id: UUID(), title: "Volvemos a Flor Shop", subtitle: "y pulsamos en Pegar Imagen", imageText: "View3"),
            OnboardItem(id: UUID(), title: "Damos permiso para pegar", subtitle: "pulsamos en 'Permitir pegar'", imageText: "View4"),
            OnboardItem(id: UUID(), title: "Completamos los demas datos", subtitle: "Luego pulsamos en Guardar", imageText: "View5"),
            OnboardItem(id: UUID(), title: "Podemos deslizar hacia la derecha para agregar un producto al carrito", subtitle: "o a la izquierda para editarlo", imageText: "View6"),
            OnboardItem(id: UUID(), title: "En el carrito podemos aumentar la cantidad con el botón +", subtitle: "presionamos en Vender y se reducirá el stock!!!", imageText: "View7")
        ]
        return onboardItems
    }
}

#Preview {
    OnboardingView()
}
