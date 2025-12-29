import SwiftUI

struct SubsidiarySelectionTopBar: View {
    var tittleBar: String = "Agregar Producto"
    let backAction: () -> Void
    var body: some View {
        HStack {
            BackButton(backAction: backAction)
            Spacer()
            Text(tittleBar)
                .font(.title2)
                .foregroundColor(Color.black)
            Spacer()
            Spacer()
                .frame(width: 40, height: 40)
        }
    }
}

#Preview {
    SubsidiarySelectionTopBar(
        tittleBar: "Elige una tienda",
        backAction: {}
    )
    .background(Color.background)
}
