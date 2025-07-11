import SwiftUI

struct WebSocketErrorView: View {
    var body: some View {
        ZStack{
            Color.black.opacity(0.1)
                .ignoresSafeArea()
                .blur(radius: 5)
            VStack{
                Image(systemName: "wifi.exclamationmark")
                    .foregroundStyle(Color.black)
                    .font(.system(size: 80, weight: .bold))
                Text("Se perdió la conexión con el servidor")
                    .foregroundStyle(Color.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
}

#Preview {
    VStack{
        WebSocketErrorView()
    }
}
