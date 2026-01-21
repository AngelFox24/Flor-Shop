import SwiftUI
import AVFoundation

struct CartTopToolbar: ToolbarContent {
    @Binding var cartViewModel: CartViewModel
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationButton(push: .selectCustomer) {
                if let customer = cartViewModel.customerInCar {
                    CustomAsyncImageView(imageUrlString: customer.imageUrl, size: 40)
                        .contextMenu(menuItems: {
                            Button(role: .destructive) {
                                cartViewModel.customerInCar = nil
                            } label: {
                                Text("Desvincular Cliente")
                            }
                        })
                } else {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        ToolbarSpacer(.fixed, placement: .confirmationAction)
        ToolbarItem(placement: .confirmationAction) {
            NavigationBasicButton(push: .payment, systemImage: "checkmark")
        }
    }
}
