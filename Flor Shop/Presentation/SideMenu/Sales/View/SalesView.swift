//
//  SalesView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/12/23.
//

import SwiftUI

struct SalesView: View {
    @EnvironmentObject var salesViewModel: SalesViewModel
    @Binding var showMenu: Bool
    var backButton: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            SalesTopBar(showMenu: $showMenu)
            SalesListController()
        }
        .onAppear {
            salesViewModel.lazyFetchList()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

struct SalesView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        SalesView(showMenu: .constant(false))
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(dependencies.navManager)
    }
}

struct SalesListController: View {
    @EnvironmentObject var salesViewModel: SalesViewModel
    @EnvironmentObject var navManager: NavManager
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if salesViewModel.salesDetailsList.count == 0 {
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
                        ForEach(salesViewModel.salesDetailsList) { saleDetail in
                            CardViewTipe2(
                                id: saleDetail.image?.id,
                                url: saleDetail.image?.imageUrl,
                                mainText: saleDetail.productName,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(saleDetail.subtotal),
                                mainIndicatorAlert: false,
                                secondaryIndicatorSuffix: " u",
                                secondaryIndicator: String(saleDetail.quantitySold),
                                secondaryIndicatorAlert: false, size: 80
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .onTapGesture {
                                
                            }
                            .onAppear(perform: {
                                if salesViewModel.shouldSalesDetailsListLoadData(saleDetail: saleDetail) {
                                    salesViewModel.fetchSalesDetailsListNextPage()
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

