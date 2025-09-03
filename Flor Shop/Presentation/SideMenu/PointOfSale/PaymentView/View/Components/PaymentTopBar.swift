import SwiftUI

struct PaymentTopBar: View {
    let backAction: () -> Void
    let registerSale: () -> Void
    var body: some View {
        HStack {
            HStack(content: {
                BackButton(backAction: backAction)
                Spacer()
                Button(action: registerSale) {
                    CustomButton1(text: "Finalizar")
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
    PaymentTopBar(backAction: {}, registerSale: {})
}
