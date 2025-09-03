import SwiftUI

struct SalesView: View {
    @State var salesViewModel: SalesViewModel
    @Binding var showMenu: Bool
    init(ses: SessionContainer, showMenu: Binding<Bool>) {
        self.salesViewModel = SalesViewModelFactory.getSalesViewModel(sessionContainer: ses)
        self._showMenu = showMenu
    }
    var body: some View {
        ZStack {
            if !showMenu {
                VStack(spacing: 0, content: {
                    Color.primary
                    Color.background
                })
                .ignoresSafeArea()
            }
            VStack(spacing: 0) {
                SalesTopBar(salesCoreDataViewModel: $salesViewModel) {
                    showMenu.toggle()
                }
                SalesListController()
            }
            .background(Color.primary)
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

#Preview {
    SalesView(ses: SessionContainer.preview, showMenu: .constant(false))
}

struct SalesListController: View {
    @Environment(SalesViewModel.self) var salesViewModel
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

