import SwiftUI

struct CustomerHistoryTopBar: View {
    let customer: Customer?
    let backAction: () -> Void
    let payDebt: () -> Void
    var body: some View {
        HStack {
            BackButton(backAction: backAction)
            Spacer()
            Button(action: payDebt) {
                HStack(spacing: 5) {
                    Text(String("S/. "))
                        .font(.custom("Artifika-Regular", size: 15))
                    Text(String(format: "%.2f", customer?.totalDebt.soles ?? 0.0))
                        .font(.custom("Artifika-Regular", size: 20))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .foregroundColor(Color.background)
                .background(Color.accent)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            if let customer = customer {
                NavigationButton(push: .addCustomer) {
                    CustomAsyncImageView(imageUrlString: customer.imageUrl, size: 40)
                }
            } else {
                EmptyProfileButton()
            }
        }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CustomerHistoryTopBar(
        customer: Customer(
            id: UUID(),
            customerCic: UUID().uuidString,
            name: "Test Customer",
            lastName: "Tests Last Name",
            creditLimit: .init(2450),
            creditDays: 23,
            creditScore: 3000,
            dateLimit: Date(),
            phoneNumber: "99855352",
            lastDatePurchase: Date(),
            totalDebt: .init(7564),
            isCreditLimitActive: false,
            isDateLimitActive: false
        ),
        backAction: {},
        payDebt: {}
    )
    .environment(mainRouter)
    .background(Color.primary)
}

