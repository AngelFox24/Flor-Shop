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
        ZStack(content: {
            if !showMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                    Color("color_background")
                })
                .ignoresSafeArea()
            }
            VStack(spacing: 0) {
                SalesTopBar(showMenu: $showMenu)
                SalesListController()
            }
            .padding(.vertical, showMenu ? 15 : 0)
            .background(Color("color_primary"))
            .cornerRadius(showMenu ? 35 : 0)
            .padding(.top, showMenu ? 0 : 1)
            .disabled(showMenu ? true : false)
            .onAppear {
                salesViewModel.lazyFetchList()
            }
            .onDisappear(perform: {
                salesViewModel.releaseResources()
            })
            if showMenu {
                VStack(spacing: 0, content: {
                    Color("color_primary")
                        .opacity(0.001)
                })
                .onTapGesture(perform: {
                    withAnimation(.easeInOut) {
                        showMenu = false
                    }
                })
                .disabled(showMenu ? false : true)
            }
        })
    }
}

struct SalesView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        SalesView(showMenu: .constant(false))
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.salesViewModel)
            .environmentObject(nor.navManager)
    }
}

struct SalesListController: View {
    @EnvironmentObject var salesViewModel: SalesViewModel
    @EnvironmentObject var navManager: NavManager
    var body: some View {
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
                            imageUrl: saleDetail.image,
                            mainText: saleDetail.productName,
                            mainIndicatorPrefix: "S/. ",
                            mainIndicator: String(saleDetail.subtotal.cents),
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
                .scrollIndicators(ScrollIndicatorVisibility.hidden)
                .listStyle(PlainListStyle())
            }
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
}

