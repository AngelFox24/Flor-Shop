import SwiftUI

struct PaymentView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var paymentViewModel: PaymentViewModel
    init(ses: SessionContainer) {
        paymentViewModel = PaymentViewModelFactory.getPaymentViewModel(sessionContainer: ses)
    }
    var body: some View {
        PaymentsFields(paymentViewModel: $paymentViewModel)
            .padding(.horizontal, 10)
            .background(Color.background)
            .disabled(paymentViewModel.isLoading)
            .alert(alert: $paymentViewModel.alert, alertInfo: paymentViewModel.alertInfo)
            .toolbar {
                MainConfirmationAsyncToolbar(disabled: paymentViewModel.disabled,isLoading: paymentViewModel.isLoading, action: paymentViewModel.setSaleTransacction)
            }
            .onDisappear {
                paymentViewModel.registerTask?.cancel()
                paymentViewModel.registerTask = nil
                paymentViewModel.isLoading = false
            }
            .task(id: paymentViewModel.paymentTransaction) {
                guard self.paymentViewModel.paymentTransaction != .none else { return }
                switch self.paymentViewModel.paymentTransaction {
                case .send(let car, let customer, let paymentType):
                    await self.paymentViewModel.registerSale()
                    self.paymentViewModel.paymentTransaction = .none
                default:
                    self.paymentViewModel.paymentTransaction = .none
                    return
                }
            }
            .task {
                await self.paymentViewModel.fetchCart()
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
                    Text(paymentViewModel.totalDisplay)
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
