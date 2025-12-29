import SwiftUI
import AVFoundation

struct CartTopBar: View {
    @Binding var cartViewModel: CartViewModel
    let backAction: () -> Void
    var body: some View {
        HStack {
            HStack{
                BackButton(backAction: backAction)
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
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                NavigationButton(push: .selectCustomer) {
                    if let customer = cartViewModel.customerInCar {
                        CustomAsyncImageView(imageUrlString: customer.imageUrl, size: 40)
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
    }
}

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
    }
}

#Preview {
    @Previewable @State var cartViewModel = CartViewModelFactory.getCartViewModel(sessionContainer: SessionContainer.preview)
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CartTopBar(cartViewModel: $cartViewModel, backAction: {})
        .environment(mainRouter)
        .background(Color.primary)
}
