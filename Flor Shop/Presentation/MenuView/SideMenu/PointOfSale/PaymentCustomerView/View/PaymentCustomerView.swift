import SwiftUI

struct PaymentCustomerView: View {
    @Environment(FlorShopRouter.self) private var router
    @Environment(OverlayViewModel.self) private var overlayViewModel
    @State var paymentViewModel: PaymentCustomerViewModel
    let customerCic: String
    init(customerCic: String, ses: SessionContainer) {
        paymentViewModel = PaymentCustomerViewModelFactory.getPaymentViewModel(sessionContainer: ses)
        self.customerCic = customerCic
    }
    var body: some View {
        PaymentsCustomerFields(paymentViewModel: $paymentViewModel)
            .padding(.horizontal, 10)
            .background(Color.background)
            .toolbar {
                MainConfirmationToolbar(disabled: false, action: payCustomerTotalDebd)
            }
            .task {
                await self.paymentViewModel.updateUI(customerCic: customerCic)
            }
    }
    func payCustomerTotalDebd() {
        let loadingId = self.overlayViewModel.showLoading(origin: "[PaymentCustomerView]")
        Task {
            do {
                try await self.paymentViewModel.payCustomerTotalDebd()
                router.back()
                self.overlayViewModel.endLoading(id: loadingId, origin: "[PaymentCustomerView]")
            } catch {
                print("Error al registrar la venta: \(error.localizedDescription)")
                self.overlayViewModel.showAlert(
                    title: "Error",
                    message: "Ha ocurrido un error al pagar la deuda. Inténtalo más tarde.",
                    primary: ConfirmAction(
                        title: "Aceptar",
                        action: {
                            self.overlayViewModel.endLoading(id: loadingId, origin: "[PaymentCustomerView]")
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
    PaymentCustomerView(customerCic: UUID().uuidString, ses: SessionContainer.preview)
        .environment(mainRouter)
        .environment(overlayViewModel)
}

struct PaymentsCustomerFields: View {
    @Binding var paymentViewModel: PaymentCustomerViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("S/.")
                        .font(.custom("Artifika-Regular", size: 26))
                        .foregroundColor(.black)
                    Text("\(paymentViewModel.customer?.totalDebt.solesString, default: "0")")
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
                VStack {
                    if let customer = paymentViewModel.customer {
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
                    } else {
                        CardViewPlaceHolder1(size: 80)
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
