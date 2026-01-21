import SwiftUI

struct SalesBottomToolbar: ToolbarContent {
    @Binding var salesViewModel: SalesViewModel
    var body: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button("Back Date", systemImage: "chevron.backward") {
                previousDate()
            }
        }
        ToolbarItem(placement: .bottomBar) {
            Button("Next Date", systemImage: "chevron.forward") {
                nextDate()
            }
        }
        ToolbarSpacer(placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                salesViewModel.salesCurrentDateFilter = Date()
                salesViewModel.updateAmountsBar()
                salesViewModel.fetchSalesDetailsList()
            } label: {
                Text("Hoy")
            }
        }
    }
    func nextDate() {
        salesViewModel.nextDate()
        salesViewModel.updateAmountsBar()
        salesViewModel.fetchSalesDetailsList()
    }
    func previousDate() {
        salesViewModel.previousDate()
        salesViewModel.updateAmountsBar()
        salesViewModel.fetchSalesDetailsList()
    }
}
