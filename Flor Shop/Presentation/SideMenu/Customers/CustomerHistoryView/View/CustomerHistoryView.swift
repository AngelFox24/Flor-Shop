//
//  CustomerHistoryView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 22/03/24.
//

import SwiftUI
struct CustomerHistoryView: View {
    @EnvironmentObject var customerHistoryViewModel: CustomerHistoryViewModel
    var body: some View {
        VStack(spacing: 0) {
            CustomerHistoryTopBar()
            CustomerHistoryViewListController()
        }
        .onAppear(perform: {
            customerHistoryViewModel.lazyFetch()
        })
        .onDisappear(perform: {
            customerHistoryViewModel.releaseResources()
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct CustomerHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CustomerHistoryView()
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(dependencies.customerHistoryViewModel)
    }
}
struct CustomerHistoryViewListController: View {
    @Environment(Router.self) private var router
    @EnvironmentObject var customerHistoryViewModel: CustomerHistoryViewModel
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if customerHistoryViewModel.salesDetail.count == 0 {
                    VStack {
                        Image("groundhog_finding")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 300)
                        Text("No hay ventas aún.")
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .font(.custom("Artifika-Regular", size: 18))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(customerHistoryViewModel.salesDetail) { saleDetail in
                            let day: String = saleDetail.saleDate.getDateComponent(dateComponent: .day).description
                            let month: String = saleDetail.saleDate.getShortNameComponent(dateStringNameComponent: .month)
                            let year: String = saleDetail.saleDate.getDateComponent(dateComponent: .year).description
                            CardViewTipe2(
                                imageUrl: saleDetail.image,
                                topStatusColor: saleDetail.paymentType == PaymentType.cash ? .green : .red,
                                topStatus: saleDetail.paymentType == PaymentType.cash ? "Pagado \(day) \(month) \(year)" : "Sin Pagar \(day) \(month) \(year)",
                                mainText: saleDetail.productName,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(format: "%.2f", saleDetail.subtotal.soles),
                                mainIndicatorAlert: false,
                                secondaryIndicatorSuffix: "u",
                                secondaryIndicator: String(saleDetail.quantitySold),
                                secondaryIndicatorAlert: false, size: 80
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .onTapGesture {
                                
                            }
                            .onAppear(perform: {
                                if customerHistoryViewModel.shouldLoadData(salesDetail: saleDetail) {
                                    customerHistoryViewModel.fetchNextPage()
                                }
                            })
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .padding(.horizontal, 10)
            .background(Color("color_background"))
        }
    }
}
