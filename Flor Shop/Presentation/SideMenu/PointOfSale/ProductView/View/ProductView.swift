//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData
import AVFoundation
import StoreKit

struct CustomProductView: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var viewStates: ViewStates
    @FocusState var currentFocusField: AllFocusFields?
    @EnvironmentObject var errorState: ErrorState
    @State private var audioPlayer: AVAudioPlayer?
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0) {
            ProductSearchTopBar(currentFocusField: $currentFocusField)
            ListaControler(selectedTab: $selectedTab)
        }
        .onChange(of: viewStates.focusedField, perform: { newVal in
            print("Ext cambio: \(viewStates.focusedField)")
            currentFocusField = viewStates.focusedField
        })
        .onChange(of: currentFocusField, perform: { newVal in
            print("curr cambio: \(currentFocusField)")
            viewStates.focusedField = currentFocusField
        })
        .onAppear {
            sync()
            productsCoreDataViewModel.lazyFetchProducts()
            self.currentFocusField = viewStates.focusedField
        }
        .onDisappear {
            productsCoreDataViewModel.releaseResources()
        }
    }
    private func sync() {
        Task {
            viewStates.isLoading = true
//            try? await Task.sleep(nanoseconds: 2_000_000_000)
            do {
                try await productsCoreDataViewModel.sync()
                playSound(named: "Success1")
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
                playSound(named: "Fail1")
            }
            viewStates.isLoading = false
        }
    }
    private func playSound(named fileName: String) {
        var soundURL: URL?
        soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        guard let url = soundURL else {
            print("No se pudo encontrar el archivo de sonido.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("No se pudo reproducir el sonido. Error: \(error.localizedDescription)")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let nor = NormalDependencies()
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CustomProductView(selectedTab: .constant(.magnifyingglass))
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
            .environmentObject(nor.viewStates)
    }
}

struct ListaControler: View {
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @EnvironmentObject var viewStates: ViewStates
    @EnvironmentObject var errorState: ErrorState
    @State private var showingErrorAlert = false
    @AppStorage("isRequested20AppRatingReview") var isRequested20AppRatingReview: Bool = true
    @Environment(\.requestReview) var requestReview
    @State private var audioPlayer: AVAudioPlayer?
    @State var unitPoint: UnitPoint = .bottom
    @State var lastIndex: Int = 0
    @Binding var selectedTab: Tab
    var body: some View {
        HStack(spacing: 0) {
            if productsCoreDataViewModel.productsCoreData.count == 0 {
                VStack {
                    Image("groundhog_finding")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)
                    Text("Agreguemos productos a nuestra tienda.")
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .font(.custom("Artifika-Regular", size: 18))
                    Button(action: {
                        goToEditProduct()
                    }, label: {
                        CustomButton1(text: "Agregar")
                    })
//                    Button(action: {
//                        agregarViewModel.loadTestData()
//                    }, label: {
//                        CustomButton1(text: "Data de Prueba")
//                    })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("color_background"))
                .onAppear {
                    productsCoreDataViewModel.lazyFetchProducts()
                }
            } else {
                SideSwipeView(swipeDirection: .right, swipeAction: goToEditProduct)
                HStack(spacing: 0, content: {
                    List {
                        ForEach(0 ..< productsCoreDataViewModel.deleteCount, id: \.self) { _ in
                            let _ = print("Spacios: \(productsCoreDataViewModel.deleteCount.description)")
                            Spacer()
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .onAppear {
                                    productsCoreDataViewModel.releaseResources()
                                    productsCoreDataViewModel.lazyFetchProducts()
                                }
                        }
                        ForEach(productsCoreDataViewModel.productsCoreData) { producto in
                            CardViewTipe2(
                                imageUrl: producto.image,
                                topStatusColor: Color.red,
                                topStatus: nil,
                                mainText: producto.name,
                                mainIndicatorPrefix: "S/. ",
                                mainIndicator: String(format: "%.2f", producto.unitPrice.soles),
                                mainIndicatorAlert: false,
                                secondaryIndicatorSuffix: " u",
                                secondaryIndicator: String(producto.qty),
                                secondaryIndicatorAlert: false, size: 80
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .listRowBackground(Color("color_background"))
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(action: {
                                    agregarProductoACarrito(producto: producto)
                                }, label: {
                                    Image(systemName: "cart")
                                })
                                .tint(Color("color_accent"))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(action: {
                                    editProduct(product: producto)
                                    selectedTab = .plus
                                }, label: {
                                    Image(systemName: "pencil")
                                })
                                .tint(Color("color_accent"))
                            }
                            .onAppear(perform: {
                                print("Aparece item con Id: \(producto.id)")
                                productsCoreDataViewModel.shouldLoadData(product: producto)
                                if productsCoreDataViewModel.productsCoreData.count >= 20 && isRequested20AppRatingReview {
                                    requestReview()
                                    isRequested20AppRatingReview = false
                                }
                            })
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
//                    .padding(.horizontal, 10)
                    .listStyle(PlainListStyle())
                })
                SideSwipeView(swipeDirection: .left, swipeAction: goToCart)
            }
        }
        .background(Color("color_background"))
    }
    func goToEditProduct() {
        selectedTab = .plus
    }
    func goToCart() {
        selectedTab = .cart
    }
    func editProduct(product: Product) {
        Task {
            viewStates.isLoading = true
            do {
                try await agregarViewModel.editProduct(product: product)
                playSound(named: "Success1")
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
                playSound(named: "Fail1")
            }
            viewStates.isLoading = false
        }
    }
    func agregarProductoACarrito(producto: Product) {
        Task {
            viewStates.isLoading = true
            do {
                try await carritoCoreDataViewModel.addProductoToCarrito(product: producto)
                playSound(named: "Success1")
            } catch {
                await MainActor.run {
                    errorState.processError(error: error)
                }
                playSound(named: "Fail1")
            }
            viewStates.isLoading = false
        }
    }
    private func playSound(named fileName: String) {
        var soundURL: URL?
        soundURL = Bundle.main.url(forResource: fileName, withExtension: "mp3")
        guard let url = soundURL else {
            print("No se pudo encontrar el archivo de sonido.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("No se pudo reproducir el sonido. Error: \(error.localizedDescription)")
        }
    }
}
