import SwiftUI

struct CustomerHistoryTopBar: ToolbarContent {
    let customer: Customer
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationButton(push: .selectCustomer) {
                CustomAsyncImageView(imageUrlString: customer.imageUrl, size: 45)
                    .clipShape(Circle())
            }
            .buttonStyle(.borderless)
        }
        .sharedBackgroundVisibility(.hidden)
        ToolbarSpacer(.fixed, placement: .confirmationAction)
        if let customerCic = customer.customerCic {
            ToolbarItem(placement: .confirmationAction) {
                NavigationBasicButton(push: .payCustomerTotalDebd(customerCic: customerCic), systemImage: "checkmark")
            }
        }
    }
}
