//
//  CartViewTipe1.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 26/09/23.
//

import SwiftUI

struct CardViewTipe1: View {
    //No se declara modelos de datos de capa vista porque se reutilizara para varias vistas
    let image: ImageUrl
    let topStatusColor: Color
    let topStatus: String
    let mainText: String
    let secondaryText: String
    let size: CGFloat
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CustomAsyncImageView(id: image.id, urlProducto: image.imageUrl, size: size)
                VStack(spacing: 2) {
                    HStack{
                        topStatusColor
                            .frame(width: 10, height: 10)
                            .cornerRadius(15)
                        Text(topStatus)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 9))
                        Spacer()
                    }
                    HStack {
                        Text(mainText)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    HStack {
                        Text(secondaryText)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 11))
                        Spacer()
                    }
                }
                .padding(.vertical, 6)
                HStack{
                    Image(systemName: "chevron.backward")
                        .foregroundColor(Color("color_accent"))
                        .font(.custom("Artifika-Regular", size: 22))
                        .rotationEffect(.degrees(180))
                        .padding(.horizontal, 12)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}

struct CardViewTipe2: View {
    var image: ImageUrl
    var topStatusColor: Color?
    var topStatus: String?
    var mainText: String
    var mainIndicatorPrefix: String?
    var mainIndicator: String
    var mainIndicatorAlert: Bool
    var secondaryIndicatorSuffix: String?
    var secondaryIndicator: String?
    var secondaryIndicatorAlert: Bool
    let size: CGFloat
    var body: some View {
        VStack {
            HStack {
                CustomAsyncImageView(id: image.id, urlProducto: image.imageUrl, size: size)
                VStack(spacing: 2) {
                    if let topStatusUnwrap = topStatus, let topStatusColorUnwrap = topStatusColor {
                        HStack{
                            topStatusColorUnwrap
                                .frame(width: 10, height: 10)
                                .cornerRadius(15)
                            Text(topStatusUnwrap)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 9))
                            Spacer()
                        }
                    }
                    HStack {
                        Text(mainText)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }
                    HStack {
                        if let secondaryIndicatorUnwrap = secondaryIndicator {
                            HStack(spacing: 0){
                                Text(secondaryIndicatorUnwrap)
                                    .foregroundColor(.black)
                                    .font(.custom("Artifika-Regular", size: 16))
                                if let secondaryIndicatorSuffixUnwrap = secondaryIndicatorSuffix {
                                    Text(secondaryIndicatorSuffixUnwrap)
                                        .foregroundColor(.black)
                                        .font(.custom("Artifika-Regular", size: 12))
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 10)
                            .background(secondaryIndicatorAlert ? Color(.red) : Color("color_secondary"))
                            .cornerRadius(20)
                            Spacer()
                        }
                    }
                }
                .padding(.vertical, 6)
                VStack {
                    HStack(spacing: 0) {
                        if let mainIndicatorPrefixUnwrap = mainIndicatorPrefix {
                            Text(mainIndicatorPrefixUnwrap)
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 14))
                        }
                        Text(mainIndicator)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(mainIndicatorAlert ? Color(.red) : Color("color_secondary"))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}

struct CardViewTipe3: View {
    // let cartDetail: CartDetail
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    let cartDetail: CartDetail
    let size: CGFloat
    var decreceProductAmount: (CartDetail) -> Void
    var increaceProductAmount: (CartDetail) -> Void
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                CustomAsyncImageView(id: cartDetail.product.image.id, urlProducto: cartDetail.product.image.imageUrl, size: size)
                VStack {
                    HStack {
                        Text(cartDetail.product.name)
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .padding(.top, 6)
                    HStack {
                        Button(action: {}, label: {
                            Image(systemName: "minus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        })
                        .highPriorityGesture(TapGesture().onEnded {
                            decreceProductAmount(cartDetail)
                        })
                        HStack { // Cantidad Producto
                            Text(String(cartDetail.quantity)+" u")
                                .foregroundColor(.black)
                                .font(.custom("Artifika-Regular", size: 16))
                                .padding(.vertical, 2)
                                .padding(.horizontal, 10)
                                .background(Color("color_secondary"))
                                .cornerRadius(20)
                        }
                        Button(action: {}, label: {
                            Image(systemName: "plus")
                                .resizable()
                                .font(.headline)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .padding(8)
                                .foregroundColor(Color("color_accent"))
                                .background(Color("color_secondary"))
                                .clipShape(Circle())
                        })
                        .highPriorityGesture(TapGesture().onEnded {
                            increaceProductAmount(cartDetail)
                        })
                        Spacer()
                    }
                }
                .padding(.bottom, 6)
                VStack {
                    HStack(spacing: 0) {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 14))
                        Text(String(cartDetail.product.unitPrice))
                            .font(.custom("Artifika-Regular", size: 16))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .foregroundColor(.black)
                    .background(Color("color_secondary"))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 10)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}

struct CardViewTipe4: View {
    var icon: String
    var text: String
    var enable: Bool = false
    var body: some View {
        VStack(spacing: 0, content: {
            Spacer()
            Image(systemName: icon)
                .font(.custom("Artifika-Regular", size: 28))
                .foregroundColor(enable ? Color("color_background") : Color("color_primary"))
            Spacer()
            Text(text)
                .font(.custom("Artifika-Regular", size: 15))
                .foregroundColor(enable ? Color("color_background") : Color("color_primary"))
            Spacer()
        })
        .frame(width: 80, height: 80)
        .background(enable ? Color("color_accent") : Color(.white))
        .cornerRadius(15)
    }
}

struct CardViewPlaceHolder1: View {
    //No se declara modelos de datos de capa vista porque se reutilizara para varias vistas
    let size: CGFloat
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                //CustomAsyncImageView(id: image.id, urlProducto: image.imageUrl, size: size)
                VStack {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.system(size: 44))
                    //.scaledToFit()
                }
                .foregroundColor(.gray)
                .padding(.vertical, 25)
                .frame(width: size, height: size)
                .background(Color("color_secondary"))
                .cornerRadius(15)
                VStack(spacing: 2) {
                    HStack {
                        Text("Agregar Cliente")
                            .foregroundColor(.black)
                            .font(.custom("Artifika-Regular", size: 16))
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .padding(.vertical, 6)
            }
            .frame(maxWidth: .infinity, maxHeight: size)
            .background(.white)
        }
        .cornerRadius(15)
    }
}

struct CardViewPlaceHolder2: View {
    var text: String = "Agregar Imagen"
    let size: CGFloat
    var body: some View {
        VStack(spacing: 4, content: {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 55))
            Text(text)
                .font(.custom("Artifika-Regular", size: 18))
                .multilineTextAlignment(.center)
        })
        .padding(.vertical, 10)
        .foregroundColor(.black)
        .frame(width: size, height: size)
        .background(Color(.white))
        .cornerRadius(15)
    }
}

struct CardViews_Previews: PreviewProvider {
    static var previews: some View {
        let dependencies = Dependencies()
        VStack(spacing: 10, content: {
            CardViewTipe1(image: ImageUrl.getDummyImage(), topStatusColor: Color(.red), topStatus: "Manager", mainText: "Pedro Gonzales", secondaryText: "Flor Shop - Santa Anita", size: 80)
            CardViewTipe2(image: ImageUrl.getDummyImage(), topStatusColor: Color.red, topStatus: "Manager", mainText: "Carlos", mainIndicatorPrefix: "S/. ", mainIndicator: "23.00", mainIndicatorAlert: false, secondaryIndicatorSuffix: " u", secondaryIndicator: "9", secondaryIndicatorAlert: true, size: 80)
            let cartManager = LocalCartManager(mainContext: CoreDataProvider.shared.viewContext)
            let cartRepository = CarRepositoryImpl(manager: cartManager)
            let cartDetail = CartDetail(id: UUID(), quantity: 24, subtotal: 34, product: Product(id: UUID(uuidString: "3062F3B7-14C7-4314-B342-1EC912EBD925") ?? UUID(), active: true, name: "AUDIFONOS C NOISE CANCELLING 1000XM4BMUC", qty: 23, unitCost: 23.4, unitPrice: 12.4, expirationDate: Date(), image: ImageUrl(id: UUID(), imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRenBX4ycM2_FQOz3IYXI1Waln52auoUqqdVQ&usqp=CAU")))
            CardViewTipe3(cartDetail: cartDetail, size: 80, decreceProductAmount: {_ in }, increaceProductAmount: {_ in })
                .environmentObject(dependencies.cartViewModel)
            CardViewTipe4(icon: "plus", text: "Puerco")
            CardViewPlaceHolder1(size: 80)
            CardViewPlaceHolder2(size: 150)
        })
        .frame(maxHeight: .infinity)
        .background(Color.gray)
    }
}
// Sirve para saber el alto y ancho de un objeto
/*
 struct SomeView: View {
     
     @State var sizeX: CGSize = .zero
     
     var body: some View {
         VStack {
             
             Text("hello")
                 .saveSize(in: $sizeX)
         }
        let _ = print ("width: \(sizeX.width) height: \(sizeX.height)")
         
     }
 }
struct SizeCalculator: ViewModifier {
    @Binding var size: CGSize
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear // we just want the reader to get triggered, so let's use an empty color
                        .onAppear {
                            size = proxy.size
                        }
                }
            )
    }
}
extension View {
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}
 */
