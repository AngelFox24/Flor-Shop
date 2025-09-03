import SwiftUI

struct EditCustomerView: View {
    @Environment(FlorShopRouter.self) private var router
    @State var addCustomerViewModel: AddCustomerViewModel
    let customerId: UUID
    init(
        ses: SessionContainer,
        customerId: UUID
    ) {
        addCustomerViewModel = AddCustomerViewModelFactory.getAddCustomerViewModel(sessionContainer: ses)
        self.customerId = customerId
    }
    var body: some View {
        ZStack(content: {
            VStack(spacing: 0) {
                AddCustomerTopBar {
                    router.back()
                } saveCustomerAction: {
                    addCustomer()
                }
                AddCustomerFields(addCustomerViewModel: $addCustomerViewModel)
            }
            .background(Color.background)
            .task {
                addCustomerViewModel.loadCustomer(id: customerId)
            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    func addCustomer() {
        Task {
//            router.isLoading = true
            do {
                try await addCustomerViewModel.addCustomer()
                router.back()
            } catch {
                print("Error al agregar cliente: \(error)")
            }
//            router.isLoading = false
        }
    }
}

#Preview {
    EditCustomerView(ses: SessionContainer.preview, customerId: UUID())
}
