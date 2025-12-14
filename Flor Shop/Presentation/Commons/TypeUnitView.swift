import SwiftUI
import FlorShopDTOs

struct customViewPre: View {
    @State private var selection: UnitType = .unit
    var body: some View {
        TypeUnitView(value: $selection)
    }
}

struct TypeUnitView: View {
//    @State private var selection: UnitTypeEnum = .unit
    @Binding var value: UnitType
    var body: some View {
        VStack {
            HStack {
                HStack {
                    HStack {
                        Image(systemName: value == .unit ? "circle.inset.filled" : "circle")
                            .foregroundStyle(Color.accent)
                            .font(.system(size: 30))
                    }
                    Text("Unidad")
                        .foregroundColor(.black)
                        .font(.custom("Artifika-Regular", size: 20))
                        .multilineTextAlignment(.center)
                }
                .onTapGesture(perform: {
                    value = .unit
                    //agregarViewModel.agregarFields.unitType = true
                })
                Spacer()
                HStack {
                    HStack {
                        Image(systemName: value == .unit ? "circle" : "circle.inset.filled")
                            .foregroundStyle(Color.accent)
                            .font(.system(size: 30))
                    }
                    Text("Kilogramo")
                        .foregroundColor(.black)
                        .font(.custom("Artifika-Regular", size: 20))
                        .multilineTextAlignment(.center)
                }
                .onTapGesture(perform: {
                    value = .kilo
                    //agregarViewModel.agregarFields.unitType = false
                })
            }
//            .onAppear(perform: {
//                selection = agregarViewModel.agregarFields.unitType
//            })
//            .onChange(of: tipeUnitMes, perform: { item in
//                agregarViewModel.agregarFields.unitType = item
//            })
        }
    }
}

#Preview {
    customViewPre()
}
