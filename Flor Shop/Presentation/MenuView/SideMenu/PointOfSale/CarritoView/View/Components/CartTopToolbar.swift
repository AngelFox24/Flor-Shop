import SwiftUI
import AVFoundation

struct CartTopToolbar: ToolbarContent {
    @Binding var cartViewModel: CartViewModel
    let scannerAction: (String) -> Void
    var body: some ToolbarContent {
        if let customer = cartViewModel.customerInCar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationButton(push: .selectCustomer) {
                    CustomAsyncImageView(imageUrlString: customer.imageUrl, size: 45)
                        .clipShape(Circle())
                        .contextMenu {
                            Button(role: .destructive) {
                                cartViewModel.unlinkClient()
                            } label: {
                                Text("Desvincular Cliente")
                            }
                        }
                }
                .buttonStyle(.borderless)
            }
            .sharedBackgroundVisibility(.hidden)
        } else {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationButton(push: .selectCustomer) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        ToolbarSpacer(.fixed, placement: .confirmationAction)
        ToolbarItem(placement: .confirmationAction) {
            NavigationBasicButton(push: .payment, systemImage: "checkmark")
        }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationButton(sheet: .barcodeScanner(action: BarcodeAction(action: { code in
                scannerAction(code)
            }))) {
                Image(systemName: "barcode.viewfinder")
                    .foregroundStyle(Color.accentColor)
            }
        }
    }
}
