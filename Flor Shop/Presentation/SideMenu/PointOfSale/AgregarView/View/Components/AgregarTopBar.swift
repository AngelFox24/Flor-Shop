import SwiftUI
import Equatable

@Equatable
struct AgregarTopBar: View {
    @EquatableIgnoredUnsafeClosure
    let backAction: () -> Void
    @EquatableIgnoredUnsafeClosure
    let saveAction: () -> Void
    var body: some View {
        HStack {
            BackButton(backAction: backAction)
            Spacer()
            Button {
                saveAction()
            } label: {
                CustomButton1(text: "Guardar")
            }
        }
    }
}

#Preview {
    AgregarTopBar(backAction: {}, saveAction: {})
}
