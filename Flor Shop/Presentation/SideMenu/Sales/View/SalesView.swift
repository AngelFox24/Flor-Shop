import SwiftUI

struct SalesView: View {
    @State var salesViewModel: SalesViewModel
    let showMenu: () -> Void
    init(ses: SessionContainer, showMenu: @escaping () -> Void) {
        self.salesViewModel = SalesViewModelFactory.getSalesViewModel(sessionContainer: ses)
        self.showMenu = showMenu
    }
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SalesTopBar(salesCoreDataViewModel: $salesViewModel, backAction: showMenu)
                SalesListController(salesViewModel: $salesViewModel)
            }
            .background(Color.primary)
            .task {
                salesViewModel.lazyFetchList()
            }
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
        .background(Color.background)
    }
}

