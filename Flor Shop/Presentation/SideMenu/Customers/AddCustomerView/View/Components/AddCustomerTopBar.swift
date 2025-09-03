import SwiftUI

struct AddCustomerTopBar: View {
    let backAction: () -> Void
    let saveCustomerAction: () -> Void
    var body: some View {
        HStack {
            HStack(content: {
                BackButton(backAction: backAction)
                Spacer()
                Button(action: saveCustomerAction) {
                    CustomButton1(text: "Guardar")
                }
            })
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color.primary)
    }
}

#Preview {
    AddCustomerTopBar(
        backAction: {},
        saveCustomerAction: {}
    )
}
