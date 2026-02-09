import SwiftUI

struct PaymentView: View {
    @Environment(FlorShopRouter.self) private var router
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @State var paymentViewModel: PaymentViewModel
    init(ses: SessionContainer) {
        paymentViewModel = PaymentViewModelFactory.getPaymentViewModel(sessionContainer: ses)
    }
    var body: some View {
        PaymentsFields(paymentViewModel: $paymentViewModel)
            .padding(.horizontal, 10)
            .background(Color.background)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: registerSale)
            }
            .task {
                await self.paymentViewModel.fetchCart()
            }
    }
    func registerSale() {
        let loadingId = self.overlayViewModel.showLoading(origin: "[PaymentView]")
        Task {
            do {
                try await self.paymentViewModel.registerSale()
                router.back()
                self.overlayViewModel.endLoading(id: loadingId, origin: "[PaymentView]")
            } catch {
                print("Error al registrar la venta: \(error.localizedDescription)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al registrar la venta.",
                    primary: ConfirmAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "[PaymentView]")
                        }
                    )
                )
            }
        }
    }
}

#Preview {
    @Previewable @State var overlayViewModel = OverlayViewModel()
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    PaymentView(ses: SessionContainer.preview)
        .environment(mainRouter)
        .environment(overlayViewModel)
}

struct PaymentsFields: View {
    @Binding var paymentViewModel: PaymentViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("S/.")
                        .font(.custom("Artifika-Regular", size: 26))
                        .foregroundColor(.black)
                    Text("\(paymentViewModel.cartCoreData?.total.solesString, default: "0")")
                        .font(.custom("Artifika-Regular", size: 55))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 20)
                HStack {
                    Text("Cobrar a:")
                        .font(.custom("Artifika-Regular", size: 20))
                        .foregroundColor(.black)
                    Spacer()
                }
                NavigationButton(push: .selectCustomer) {
                    VStack {
                        if let customer = paymentViewModel.customerInCar {
                            CustomerCardView(
                                imageUrl: customer.imageUrl,
                                mainText: customer.mainText,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: customer.totalDebt.solesString,
                                mainIndicatorAlert: customer.isCreditLimit,
                                secondaryIndicatorSuffix: customer.secondaryIndicatorSuffix,
                                secondaryIndicator: customer.secondaryIndicator,
                                secondaryIndicatorAlert: customer.isDateLimit
                            )
                            .contextMenu {
                                Button(role: .destructive) {
                                    paymentViewModel.unlinkClient()
                                } label: {
                                    Text("Desvincular Cliente")
                                }
                            }
                        } else {
                            CardViewPlaceHolder1(size: 80)
                        }
                    }
                }
                HStack {
                    Spacer()
                    ForEach(paymentViewModel.paymentTypes, id: \.self) { paymentType in
                        Button {
                            paymentViewModel.paymentType = paymentType
                        } label: {
                            CardViewTipe4(icon: paymentType.icon, text: paymentType.description, enable: paymentViewModel.paymentType == paymentType)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
