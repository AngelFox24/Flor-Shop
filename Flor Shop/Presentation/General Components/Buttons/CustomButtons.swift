import SwiftUI

struct CustomButton1: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.custom("Artifika-Regular", size: 20))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color("color_accent"))
            .cornerRadius(15.0)
    }
}

struct CustomButton2: View {
    let text: String
    var backgroudColor: Color = Color("color_accent")
    var minWidthC: CGFloat = 200
    var body: some View {
        Text(text)
            .font(.custom("Artifika-Regular", size: 20))
            .frame(minWidth: minWidthC)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(backgroudColor)
            .cornerRadius(15.0)
    }
}

struct FilterButton: View {
    var body: some View {
        Image(systemName: "slider.horizontal.3")
            .modifier(FlorShopButtonStyle())
    }
}

struct EmptyProfileButton: View {
    var body: some View {
        Image(systemName: "person.crop.circle.badge.plus")
            .modifier(FlorShopButtonStyle())
    }
}

struct CustomButton4: View {
    var simbol: String = "chevron.backward"
    var body: some View {
        Image(systemName: simbol)
            .font(.custom("Artifika-Regular", size: 30))
            .foregroundColor(Color("color_background"))
            .frame(width: 50, height: 50)
            .background(Color.accent)
            .cornerRadius(30)
    }
}

struct CustomButton6: View {
    var simbol: String = "chevron.backward"
    var body: some View {
        Image(systemName: simbol)
            .font(.custom("Artifika-Regular", size: 18))
            .foregroundColor(Color("color_accent"))
            .frame(width: 30, height: 30)
            .background(.white)
            .cornerRadius(20)
    }
}

#Preview {
    @Previewable @State var router = Router()
    VStack(spacing: 10, content: {
        CustomButton1(text: "Limpiar")
        CustomButton2(text: "Limpiar")
        CustomButton4(simbol: "plus")
        CustomButton6(simbol: "chevron.backward")
        EmptyProfileButton()
        FilterButton()
    })
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.gray)
    .environment(router)
}
