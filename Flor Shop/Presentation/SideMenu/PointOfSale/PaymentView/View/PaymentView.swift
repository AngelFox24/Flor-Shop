import SwiftUI

struct PaymentView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var paymentViewModel: PaymentViewModel
    init(ses: SessionContainer) {
        paymentViewModel = PaymentViewModelFactory.getPaymentViewModel(sessionContainer: ses)
    }
    var body: some View {
        ZStack {
            PaymentsFields(paymentViewModel: $paymentViewModel)
            VStack {
                PaymentTopBar(backAction: router.back, registerSale: registerSale)
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .background(Color.background)
    }
    func registerSale() {
        Task {
            do {
                try await self.paymentViewModel.registerSale()
                router.back()
            } catch {
                print("Error al registrar la venta: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    PaymentView(ses: SessionContainer.preview)
        .environment(mainRouter)
}

struct PaymentsFields: View {
    @Binding var paymentViewModel: PaymentViewModel
    var body: some View {
        ScrollView(content: {
            VStack(spacing: 20, content: {
                HStack(content: {
                    Text("S/.")
                        .font(.custom("Artifika-Regular", size: 26))
                        .foregroundColor(.black)
                    let total = paymentViewModel.cartCoreData?.total.cents ?? 0
                    let totalD = Double(total/100)
                    Text(String(format: "%.2f", totalD))
                        .font(.custom("Artifika-Regular", size: 55))
                        .foregroundColor(.black)
                })
                .padding(.vertical, 20)
                HStack(content: {
                    Text("Cobrar a:")
                        .font(.custom("Artifika-Regular", size: 20))
                        .foregroundColor(.black)
                    Spacer()
                })
                NavigationButton(push: .selectCustomer) {
                    VStack {
                        if let customer = paymentViewModel.customerInCar {
                            CardViewTipe2(
                                imageUrl: customer.imageUrl,
                                topStatusColor: nil,
                                topStatus: nil,
                                mainText: customer.name + " " + (customer.lastName ?? ""),
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(customer.totalDebt.cents),
                                mainIndicatorAlert: customer.isCreditLimit,
                                secondaryIndicatorSuffix: nil, //TODO: poner en variable calculada
//                                    customer.isDateLimitActive ? (" " + String(customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month))) : nil,
                                secondaryIndicator: nil,//TODO: poner en variable calculada
//                                    customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
                                secondaryIndicatorAlert: customer.isDateLimit, size: 80
                            )
                            .contextMenu(menuItems: {
                                Button(role: .destructive,action: {
                                    paymentViewModel.customerInCar = nil
                                }, label: {
                                    Text("Desvincular Cliente")
                                })
                            })
                        } else {
                            CardViewPlaceHolder1(size: 80)
                        }
                    }
                }
                HStack(content: {
                    Spacer()
                    ForEach(paymentViewModel.paymentTypes, id: \.self, content: { paymentType in
                        CardViewTipe4(icon: paymentType.icon, text: paymentType.description, enable: paymentViewModel.paymentType == paymentType)
                            .onTapGesture {
                                paymentViewModel.paymentType = paymentType
                            }
                        Spacer()
                    })
                })
            })
        })
        .padding(.top, 30)
    }
}
