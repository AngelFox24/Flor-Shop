import SwiftUI

struct ErrorView: View {
    @Environment(Router.self) private var router
    let error: String
    var body: some View {
        ZStack{
            Color.black.opacity(0.1)
                .ignoresSafeArea()
                .blur(radius: 5)
            VStack{
                Text(error)
                Button(action: router.dismissAlert) {
                    Text("Aceptar")
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

#Preview {
    @Previewable @State var router = Router()
    VStack{
        ErrorView(error: "ss")
    }
    .environment(router)
}
