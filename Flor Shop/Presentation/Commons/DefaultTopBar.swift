import SwiftUI

struct DefaultTopBar: View {
    var titleBar: String = "Agregar Producto"
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(titleBar)
                    .font(.headline)
                    .foregroundColor(Color("color_secondary"))
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .background(Color("color_primary"))
    }
}

#Preview {
    DefaultTopBar(titleBar: "Agregar Producto")
}
