import SwiftUI

struct AddCustomerTopBar: View {
    let backAction: () -> Void
    let saveCustomerAction: () -> Void
    var body: some View {
        HStack {
            BackButton(backAction: backAction)
            Spacer()
            Button(action: saveCustomerAction) {
                CustomButton1(text: "Guardar")
            }
        }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    AddCustomerTopBar(
        backAction: {},
        saveCustomerAction: {}
    )
    .environment(mainRouter)
    .background(Color.primary)
}
