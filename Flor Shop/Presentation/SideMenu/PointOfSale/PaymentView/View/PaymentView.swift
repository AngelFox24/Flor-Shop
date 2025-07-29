import SwiftUI

struct PaymentView: View {
    var body: some View {
        VStack(spacing: 0) {
            PaymentTopBar()
            PaymentsFields()
        }
        .background(Color("color_background"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        @State var loading = false
        PaymentView()
            .environmentObject(dependencies.cartViewModel)
    }
}

struct PaymentsFields: View {
    @Environment(Router.self) private var router
    @EnvironmentObject var cartViewModel: CartViewModel
    var body: some View {
        ScrollView(content: {
            VStack(spacing: 20, content: {
                HStack(content: {
                    Text("S/.")
                        .font(.custom("Artifika-Regular", size: 26))
                        .foregroundColor(.black)
                    let total = cartViewModel.cartCoreData?.total.cents ?? 0
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
                VStack(content: {
                    if let customer = cartViewModel.customerInCar {
                        CardViewTipe2(
                            imageUrl: customer.image,
                            topStatusColor: customer.customerTipe.color,
                            topStatus: customer.customerTipe.description,
                            mainText: customer.name + " " + customer.lastName,
                            mainIndicatorPrefix: "S/. ",
                            mainIndicator: String(customer.totalDebt.cents),
                            mainIndicatorAlert: customer.isCreditLimit,
                            secondaryIndicatorSuffix: customer.isDateLimitActive ? (" " + String(customer.dateLimit.getShortNameComponent(dateStringNameComponent: .month))) : nil,
                            secondaryIndicator: customer.isDateLimitActive ? String(customer.dateLimit.getDateComponent(dateComponent: .day)) : nil,
                            secondaryIndicatorAlert: customer.isDateLimit, size: 80
                        )
                        .contextMenu(menuItems: {
                            Button(role: .destructive,action: {
                                cartViewModel.customerInCar = nil
                            }, label: {
                                Text("Desvincular Cliente")
                            })
                        })
                    } else {
                        CardViewPlaceHolder1(size: 80)
                    }
                })
                .onTapGesture {
//                    navManager.goToCustomerView()
                }
                HStack(content: {
                    Spacer()
                    ForEach(cartViewModel.paymentTypes, id: \.self, content: { paymentType in
                        CardViewTipe4(icon: paymentType.icon, text: paymentType.description, enable: cartViewModel.paymentType == paymentType)
                            .onTapGesture {
                                cartViewModel.paymentType = paymentType
                            }
                        Spacer()
                    })
                })
            })
        })
        .padding(.horizontal, 10)
    }
}
