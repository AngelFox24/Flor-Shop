//
//  HomeView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 12/04/23.
//

import SwiftUI
import CoreData
import AVFoundation

struct ProductView: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @Binding var selectedTab: Tab
    @Binding var showMenu: Bool
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ProductSearchTopBar(showMenu: $showMenu)
                ListaControler(selectedTab: $selectedTab)
            }
            .onAppear {
                productsCoreDataViewModel.lazyFetchProducts()
            }
            .onDisappear {
                productsCoreDataViewModel.releaseResources()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        @State var showMenu: Bool = false
        ProductView(selectedTab: .constant(.magnifyingglass), showMenu: $showMenu)
            .environmentObject(dependencies.productsViewModel)
            .environmentObject(dependencies.cartViewModel)
    }
}

struct ListaControler: View {
    @EnvironmentObject var agregarViewModel: AgregarViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @State private var audioPlayer: AVAudioPlayer?
    @State var unitPoint: UnitPoint = .bottom
    @State var lastIndex: Int = 0
    @Binding var selectedTab: Tab
    var body: some View {
        VStack(spacing: 0) {
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
                        selectedTab = .plus
                    }, label: {
                        CustomButton1(text: "Agregar")
                    })
//                    Button(action: {
//                        agregarViewModel.loadTestData()
//                    }, label: {
//                        CustomButton1(text: "Data de Prueba")
//                    })                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    productsCoreDataViewModel.lazyFetchProducts()
                }
            } else {
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
                            id: producto.image?.id,
                            url: producto.image?.imageUrl,
                            topStatusColor: Color.red,
                            topStatus: nil,
                            mainText: producto.name,
                            mainIndicatorPrefix: "S/. ",
                            mainIndicator: String(producto.unitPrice),
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
                                if agregarProductoACarrito(producto: producto) {
                                    playSound(named: "Success1")
                                } else {
                                    playSound(named: "Fail1")
                                }
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
                        })
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color("color_background"))
            }
        }
    }
    func editProduct(product: Product) {
        agregarViewModel.editProduct(product: product)
    }
    func agregarProductoACarrito(producto: Product) -> Bool {
        print("Se agrego el producto al carrito \(producto.name)")
        return carritoCoreDataViewModel.addProductoToCarrito(product: producto)
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
