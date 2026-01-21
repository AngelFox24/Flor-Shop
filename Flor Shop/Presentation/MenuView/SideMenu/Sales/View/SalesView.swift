import SwiftUI

struct SalesView: View {
    @State var salesViewModel: SalesViewModel
    let showMenu: () -> Void
    init(ses: SessionContainer, showMenu: @escaping () -> Void) {
        self.salesViewModel = SalesViewModelFactory.getSalesViewModel(sessionContainer: ses)
        self.showMenu = showMenu
    }
    var body: some View {
        SalesListController(salesViewModel: $salesViewModel)
            .navigationTitle("Ventas")
            .navigationSubtitle(salesViewModel.salesCurrentDateFilterString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                LogoToolBar(action: showMenu)
                SalesTopToolbar(salesViewModel: $salesViewModel)
                SalesBottomToolbar(salesViewModel: $salesViewModel)
            }
            .task {
                salesViewModel.lazyFetchList()
            }
            .onChange(of: salesViewModel.order) { _, _ in
                salesViewModel.fetchSalesDetailsList()
            }
            .onChange(of: salesViewModel.grouper) { _, _ in
                salesViewModel.fetchSalesDetailsList()
            }
            .onChange(of: salesViewModel.salesDateInterval) { _, _ in
                salesViewModel.updateAmountsBar()
                salesViewModel.fetchSalesDetailsList()
            }
    }
}

#Preview {
    SalesView(ses: SessionContainer.preview, showMenu: {})
}

struct SalesListController: View {
    @Binding var salesViewModel: SalesViewModel
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
                            imageUrl: saleDetail.imageUrl,
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
                        .listRowBackground(Color.background)
                        .onAppear {
                            if salesViewModel.shouldSalesDetailsListLoadData(saleDetail: saleDetail) {
                                salesViewModel.fetchSalesDetailsListNextPage()
                            }
                        }
                    }
                }
                .scrollIndicators(ScrollIndicatorVisibility.hidden)
                .listStyle(PlainListStyle())
                .safeAreaBar(edge: .top) {
                    SalesSafeAreaBar(
                        sales: salesViewModel.salesAmount.solesString,
                        cost: salesViewModel.costAmount.solesString,
                        revenue: salesViewModel.revenueAmount.solesString
                    )
                }
            }
        }
        .padding(.horizontal, 10)
        .background(Color.background)
    }
}

