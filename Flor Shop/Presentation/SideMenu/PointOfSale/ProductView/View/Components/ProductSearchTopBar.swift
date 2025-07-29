import SwiftUI

struct CustomSearchField: View {
    let placeHolder: String = "Buscar"
    @FocusState var isInputActive: Bool
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("color_accent"))
                .font(.custom("Artifika-Regular", size: 16))
                .padding(.vertical, 10)
                .padding(.leading, 10)
            TextField(placeHolder, text: $text)
                .focused($isInputActive)
                .padding(.vertical, 10)
                .font(.custom("Artifika-Regular", size: 16))
                .foregroundColor(Color("color_primary"))
                .submitLabel(.done)
                .disableAutocorrection(true)
            Button(action: {
                text = ""
            }, label: {
                Image(systemName: "x.circle")
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 16))
                    .padding(.vertical, 10)
                    .padding(.trailing, 10)
            })
        }
        .background(.white)
        .cornerRadius(20.0)
    }
}

struct ProductSearchTopBar: View {
    @Environment(Router.self) private var router
    @Environment(ProductViewModel.self) private var productViewModel
    @Environment(SyncWebSocketClient.self) private var ws
    let menuOrders: [PrimaryOrder] = PrimaryOrder.allValues
    let menuFilters: [ProductsFilterAttributes] = ProductsFilterAttributes.allValues
    var body: some View {
        @Bindable var productViewModel = productViewModel
        @Bindable var router = router
        VStack {
            HStack(spacing: 10, content: {
                FlorShopButton()
                CustomSearchField(text: $productViewModel.searchText)
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
                    Section("Conect WS") {
                        Button {
                            conectWS()
                        } label: {
                            Label("ConectWS", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                        }
                    }
                } label: {
                    FilterButton()
                }
                .onChange(of: productViewModel.primaryOrder) { _, _ in
                    loadProducts()
                }
                .onChange(of: productViewModel.filterAttribute) { _, _ in
                    loadProducts()
                }
            })
            .padding(.horizontal, 10)
        }
        .padding(.top, router.showMenu ? 15 : 0)
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
    func loadProducts() {
        Task {
            router.isLoanding = true
            await productViewModel.releaseResources()
            await productViewModel.fetchProducts()
            router.isLoanding = false
        }
    }
    private func conectWS() {
        ws.connect()
    }
}

struct SearchTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let sesConfig = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: sesConfig)
        VStack (content: {
            ProductSearchTopBar()
                .environment(dependencies.productViewModel)
            Spacer()
        })
    }
}
