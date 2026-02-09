import SwiftUI
import FlorShopDTOs

struct CustomerHistoryView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var customerHistoryViewModel: CustomerHistoryViewModel
    let customerCic: String
    init(ses: SessionContainer, customerCic: String) {
        self.customerHistoryViewModel = CustomerHistoryViewModelFactory.getCustomerHistoryViewModel(sessionContainer: ses)
        self.customerCic = customerCic
    }
    var body: some View {
        CustomerHistoryListView(customerHistoryViewModel: $customerHistoryViewModel)
            .navigationTitle("Historial")
            .navigationSubtitle(Text("\(customerHistoryViewModel.customer?.name, default: "Cliente desconocido")"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let customer = customerHistoryViewModel.customer {
                    CustomerHistoryTopBar(customer: customer)
                }
            }
            .task {
                await customerHistoryViewModel.updateUI(customerCic: customerCic)
            }
    }
}

#Preview {
    @Previewable @State var mainRouter = FlorShopRouter.previewRouter()
    CustomerHistoryView(ses: SessionContainer.preview, customerCic: UUID().uuidString)
        .environment(mainRouter)
}

struct CustomerHistoryListView: View {
    @Binding var customerHistoryViewModel: CustomerHistoryViewModel
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
                            CustomerHistoryCardView(
                                imageUrl: saleDetail.imageUrl,
                                topStatusColor: saleDetail.topStatusColor,
                                topStatus: saleDetail.topStatus,
                                mainText: saleDetail.productName,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: saleDetail.subtotal.solesString,
                                secondaryIndicatorSuffix: " \(saleDetail.unitType.shortDescription)",
                                secondaryIndicator: saleDetail.quantityDisplay
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color.background)
                            .onAppear {
                                if customerHistoryViewModel.shouldLoadData(salesDetail: saleDetail) {
                                    loadSalesHistory()
                                }
                            }
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .listStyle(PlainListStyle())
                }
            }
        }
        .padding(.horizontal, 10)
        .background(Color.background)
    }
    private func loadSalesHistory() {
        Task {
            await customerHistoryViewModel.fetchNextPage()
        }
    }
}
