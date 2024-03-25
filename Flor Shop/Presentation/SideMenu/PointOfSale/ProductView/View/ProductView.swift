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
    @Binding var showMenu: Bool
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ProductSearchTopBar(showMenu: $showMenu)
                ListaControler(selectedTab: $selectedTab)
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
                    Button(action: {
                        agregarViewModel.loadTestData()
                    }, label: {
                        CustomButton1(text: "Data de Prueba")
                    })
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                /*
                 List {
                 ForEach(productsCoreDataViewModel.productsCoreData) { producto in
                 CardViewTipe2(image: producto.image, topStatusColor: Color.red, topStatus: nil, mainText: producto.name, mainIndicatorPrefix: "S/. ", mainIndicator: String(producto.unitPrice), mainIndicatorAlert: false, secondaryIndicatorSuffix: " u", secondaryIndicator: String(producto.qty), secondaryIndicatorAlert: false, size: 80)
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
                 productsCoreDataViewModel.shouldLoadData(product: producto)
                 })
                 }
                 }
                 .listStyle(PlainListStyle())
                 }
                 */
                ScrollViewReader { scrollView in
                    List {
                        ForEach(productsCoreDataViewModel.productsCoreData.indices, id: \.self) { index in
                            let producto = productsCoreDataViewModel.productsCoreData[index]
                            CardViewTipe2(image: producto.image, topStatusColor: Color.red, topStatus: nil, mainText: producto.name, mainIndicatorPrefix: "S/. ", mainIndicator: String(producto.unitPrice), mainIndicatorAlert: false, secondaryIndicatorSuffix: " u", secondaryIndicator: String(producto.qty), secondaryIndicatorAlert: false, size: 80)
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
                                    productsCoreDataViewModel.shouldLoadData(product: producto)
                                    productsCoreDataViewModel.currentIndex = index
                                    print("Current: \(index)")
                                    if lastIndex > index {
                                        print(".top º last: \(lastIndex)")
                                        unitPoint = .top
                                        lastIndex = index
                                    } else if lastIndex < index {
                                        print(".bottom º last: \(lastIndex)")
                                        unitPoint = .bottom
                                        lastIndex = index
                                    }
                                })
                                .id(index)
                        }
                        .onChange(of: productsCoreDataViewModel.scrollToIndex) { newValue in
                            //La animacion no se sabe de donde comienza y es brusca
                            //withAnimation {
                            print("Scroll To: \(newValue)")
                            print("Anchor: \(unitPoint == .top ? ".top" : ".bottom")")
                            scrollView.scrollTo(unitPoint == .top ? newValue + 1 : newValue, anchor: unitPoint)
                            //}
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .padding(.horizontal, 10)
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
