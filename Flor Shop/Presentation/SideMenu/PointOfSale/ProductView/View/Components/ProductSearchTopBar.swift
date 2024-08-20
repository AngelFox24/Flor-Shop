//
//  BuscarTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/04/23.
//

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
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @Binding var showMenu: Bool
    let menuOrders: [PrimaryOrder] = PrimaryOrder.allValues
    let menuFilters: [ProductsFilterAttributes] = ProductsFilterAttributes.allValues
    var body: some View {
        VStack {
            HStack(spacing: 10, content: {
                CustomButton5(showMenu: $showMenu)
                CustomSearchField(text: $productsCoreDataViewModel.searchText)
                Menu {
                    Section("Ordenamiento") {
                        ForEach(menuOrders, id: \.self) { orden in
                            Button {
                                productsCoreDataViewModel.primaryOrder = orden
                            } label: {
                                Label(orden.longDescription, systemImage: productsCoreDataViewModel.primaryOrder == orden ? "checkmark" : "")
                            }
                        }
                    }
                    Section("Filtros") {
                        ForEach(menuFilters, id: \.self) { filtro in
                            Button {
                                productsCoreDataViewModel.filterAttribute = filtro
                            } label: {
                                Label(filtro.description, systemImage: productsCoreDataViewModel.filterAttribute == filtro ? "checkmark" : "")
                            }
                        }
                    }
                } label: {
                    CustomButton3(simbol: "slider.horizontal.3")
                }
                .onChange(of: productsCoreDataViewModel.primaryOrder, perform: { item in
                    productsCoreDataViewModel.releaseResources()
                    productsCoreDataViewModel.fetchProducts()
                })
                .onChange(of: productsCoreDataViewModel.filterAttribute, perform: { item in
                    productsCoreDataViewModel.releaseResources()
                    productsCoreDataViewModel.fetchProducts()
                })
            })
            .padding(.horizontal, 10)
        }
        .padding(.top, showMenu ? 15 : 0)
        .padding(.bottom, 9)
        .background(Color("color_primary"))
    }
}

struct SearchTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let sesConfig = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: sesConfig)
        @State var showMenu: Bool = false
        VStack (content: {
            ProductSearchTopBar(showMenu: $showMenu)
                .environmentObject(dependencies.productsViewModel)
            Spacer()
        })
    }
}
