import SwiftUI

struct SalesView: View {
    @EnvironmentObject var salesViewModel: SalesViewModel
    var backButton: Bool = false
    @State var showMenu: Bool = false
    var body: some View {
        ZStack {
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
            .background(Color("color_primary"))
            .cornerRadius(showMenu ? 35 : 0)
            .padding(.top, showMenu ? 0 : 1)
            .onAppear {
                salesViewModel.lazyFetchList()
            }
            .onDisappear(perform: {
                salesViewModel.releaseResources()
            })
        }
    }
}

struct SalesView_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        SalesView()
            .environmentObject(dependencies.customerViewModel)
            .environmentObject(dependencies.salesViewModel)
    }
}

struct SalesListController: View {
    @EnvironmentObject var salesViewModel: SalesViewModel
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
                            mainIndicator: String(format: "%.2f", saleDetail.subtotal.soles),
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

