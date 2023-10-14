//
//  CarritoTopBar.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 29/04/23.
//

import SwiftUI
import CoreData
import AVFoundation

struct CartTopBar: View {
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
    @EnvironmentObject var ventasCoreDataViewModel: SalesViewModel
    @EnvironmentObject var productsCoreDataViewModel: ProductViewModel
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isShowingCustomerView = false
    @State private var isShowingPaymentView = false
    var body: some View {
        HStack {
            HStack{
                Button(action: {
                    self.isShowingCustomerView = true
                }, label: {
                    //CustomButton2(text: "Vender", backgroudColor: Color("color_accent"), minWidthC: 10)
                    //.foregroundColor(Color(.black))
                    if let customer = carritoCoreDataViewModel.customerInCar {
                        CustomAsyncImageView(id: customer.id, urlProducto: customer.image.imageUrl, size: 45)
                    } else {
                        HStack(spacing: 5, content: {
                            Image(systemName: "person.crop.circle.badge.plus")
                                .foregroundColor(Color("color_primary"))
                                .font(.custom("Artifika-Regular", size: 22))
                        })
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(Color("color_background"))
                        .cornerRadius(15.0)
                    }
                })
                /*
                .sheet(isPresented: $isShowingCustomerView) {
                    CustomerViewPopUp(customerInContext: $carritoCoreDataViewModel.customerInCar)
                }
                 */
                Spacer()
                Button(action: {
                    self.isShowingPaymentView = true
                }, label: {
                    //CustomButton2(text: "Vender", backgroudColor: Color("color_accent"), minWidthC: 10)
                    //.foregroundColor(Color(.black))
                    HStack(spacing: 5, content: {
                        Text(String("S/. "))
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 15))
                        Text(String(carritoCoreDataViewModel.cartCoreData?.total ?? 0.0))
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 20))
                    })
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color("color_accent"))
                    .cornerRadius(15.0)
                })
                .sheet(isPresented: $isShowingPaymentView) {
                    PaymentView()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
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
struct CartTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let carManager = LocalCartManager(mainContext: CoreDataProvider.shared.viewContext)
        let carRepository = CarRepositoryImpl(manager: carManager)
        let saleManager = LocalSaleManager(mainContext: CoreDataProvider.shared.viewContext)
        let salesRepository = SaleRepositoryImpl(manager: saleManager)
        CartTopBar()
            .environmentObject(CartViewModel(carRepository: carRepository))
            .environmentObject(SalesViewModel(saleRepository: salesRepository))
    }
}
