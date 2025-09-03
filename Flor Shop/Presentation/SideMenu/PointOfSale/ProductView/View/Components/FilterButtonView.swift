import SwiftUI

struct FilterButtonView: View {
    @Binding var productViewModel: ProductViewModel
    let menuOrders: [PrimaryOrder] = PrimaryOrder.allValues
    let menuFilters: [ProductsFilterAttributes] = ProductsFilterAttributes.allValues
    var body: some View {
        Menu {
            Section("Ordenamiento") {
                ForEach(menuOrders, id: \.self) { orden in
                    Button {
                        productViewModel.primaryOrder = orden
                    } label: {
                        Label(orden.longDescription, systemImage: productViewModel.primaryOrder == orden ? "checkmark" : "")
                    }
                }
            }
            Section("Filtros") {
                ForEach(menuFilters, id: \.self) { filtro in
                    Button {
                        productViewModel.filterAttribute = filtro
                    } label: {
                        Label(filtro.description, systemImage: productViewModel.filterAttribute == filtro ? "checkmark" : "")
                    }
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .modifier(FlorShopButtonStyleLigth())
        }
    }
}

#Preview {
    @Previewable @State var vm = {
        let ses = SessionContainer.preview
        return ProductViewModelFactory.getProductViewModel(sessionContainer: ses)
    }()
    FilterButtonView(productViewModel: $vm)
        .background(Color.gray)
}
