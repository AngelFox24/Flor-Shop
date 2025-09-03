import SwiftUI
import AVFoundation

struct CartTopBar: View {
    @Binding var cartViewModel: CartViewModel
    let backAction: () -> Void
    var body: some View {
        HStack {
            HStack{
                FlorShopButton(backAction: backAction)
                Spacer()
                NavigationButton(push: .payment) {
                    HStack(spacing: 5, content: {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 15))
                        let total = cartViewModel.cartCoreData?.total.solesString ?? "0"
                        Text(total)
                            .font(.custom("Artifika-Regular", size: 20))
                    })
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(Color.background)
                    .background(Color.accent)
                    .cornerRadius(15.0)
                }
                NavigationButton(push: .selectCustomer) {
                    if let customer = cartViewModel.customerInCar, let image = customer.image {
                        CustomAsyncImageView(imageUrl: image, size: 40)
                            .contextMenu(menuItems: {
                                Button(role: .destructive,action: {
                                    cartViewModel.customerInCar = nil
                                }, label: {
                                    Text("Desvincular Cliente")
                                })
                            })
                    } else {
                        EmptyProfileButton()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color.primary)
    }
}

#Preview {
    @Previewable @State var cartViewModel = CartViewModelFactory.getCartViewModel(sessionContainer: SessionContainer.preview)
    CartTopBar(cartViewModel: $cartViewModel, backAction: {})
}
