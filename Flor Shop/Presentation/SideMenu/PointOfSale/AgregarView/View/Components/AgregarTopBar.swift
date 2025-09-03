import SwiftUI

struct AgregarTopBar: View {
    let backAction: () -> Void
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
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color.primary)
    }
}

#Preview {
    AgregarTopBar(backAction: {}, saveAction: {})
}
