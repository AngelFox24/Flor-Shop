import SwiftUI

struct CustomerEmptyView: View {
    var body: some View {
        EmptyView(
            imageName: "groundhog_finding",
            text: "No hay clientes registrados aún.",
            textButton: "Agregar",
            pushDestination: .addCustomer
        )
    }
}
