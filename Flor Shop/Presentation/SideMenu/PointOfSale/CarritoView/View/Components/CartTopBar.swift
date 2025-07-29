import SwiftUI
import CoreData
import AVFoundation

struct CartTopBar: View {
    // TODO: Corregir el calculo del total al actualizar precio en AgregarView
    @Environment(Router.self) private var router
    @EnvironmentObject var carritoCoreDataViewModel: CartViewModel
//    @EnvironmentObject var navManager: NavManager
    var body: some View {
        @Bindable var router = router
        HStack {
            HStack{
                FlorShopButton()
                Spacer()
                Button(action: {
                    router.presentSheet(.payment)
                    print("Se presiono cobrar")
                }, label: {
                    HStack(spacing: 5, content: {
                        Text(String("S/. "))
                            .font(.custom("Artifika-Regular", size: 15))
                        let total = carritoCoreDataViewModel.cartCoreData?.total.solesString ?? "0"
                        Text(total)
                            .font(.custom("Artifika-Regular", size: 20))
                    })
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .foregroundColor(Color("color_background"))
                    .background(Color("color_accent"))
                    .cornerRadius(15.0)
                })
                Button(action: {
//                    navManager.goToCustomerView()
                }, label: {
                    if let customer = carritoCoreDataViewModel.customerInCar, let image = customer.image {
                        CustomAsyncImageView(imageUrl: image, size: 40)
                            .contextMenu(menuItems: {
                                Button(role: .destructive,action: {
                                    carritoCoreDataViewModel.customerInCar = nil
                                }, label: {
                                    Text("Desvincular Cliente")
                                })
                            })
                    } else {
                        EmptyProfileButton()
                    }
                })
            }
        }
        .padding(.top, router.showMenu ? 15 : 0)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .background(Color("color_primary"))
    }
}
struct CartTopBar_Previews: PreviewProvider {
    static var previews: some View {
        let ses = SessionConfig(companyId: UUID(), subsidiaryId: UUID(), employeeId: UUID())
        let dependencies = BusinessDependencies(sessionConfig: ses)
        CartTopBar()
            .environmentObject(dependencies.cartViewModel)
    }
}
