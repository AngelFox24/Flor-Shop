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
    @Binding var selectedTab: Tab
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchTopBar()
                ListaControler(selectedTab: $selectedTab)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let productManager = LocalProductManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let productRepository = ProductRepositoryImpl(manager: productManager)
        let carManager = LocalCarManager(containerBDFlor: CoreDataProvider.shared.persistContainer)
        let carRepository = CarRepositoryImpl(manager: carManager)
        ProductView(selectedTab: .constant(.magnifyingglass))
            .environmentObject(ProductViewModel(productRepository: productRepository))
            .environmentObject(CartViewModel(carRepository: carRepository))
    }
}

struct ListaControler: View {
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @State private var audioPlayer: AVAudioPlayer?
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
                    Button(action: {
                        selectedTab = .plus
                    }, label: {
                        CustomButton1(text: "Agregar")
                    })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
            List {
                ForEach(productsCoreDataViewModel.productsCoreData) { producto in
                    ProductCardView(
                        id: producto.id,
                        name: producto.name,
                        expirationDate: producto.expirationDate,
                        quantity: producto.qty,
                        unitPrice: producto.unitPrice,
                        url: producto.url,
                        size: 100.0)
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
                            editarProducto(producto: producto)
                            selectedTab = .plus
                        }, label: {
                            Image(systemName: "pencil")
                        })
                        .tint(Color("color_accent"))
                    }
                }
            }
            .listStyle(PlainListStyle())
            }
        }
        .padding(.horizontal, 10)
        .background(Color("color_background"))
    }
    func editarProducto(producto: Product) {
        productsCoreDataViewModel.editProduct(product: producto)
        print("Se esta editando el producto \(producto.name)")
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
