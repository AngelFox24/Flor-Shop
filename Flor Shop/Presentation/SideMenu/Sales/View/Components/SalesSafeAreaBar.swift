import SwiftUI

struct SalesSafeAreaBar: View {
    let sales: String
    let cost: String
    let revenue: String
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("Ventas")
                    .font(.custom("Artifika-Regular", size: 13))
                    .foregroundColor(Color.primary)
                Text(sales)
                    .font(.custom("Artifika-Regular", size: 16))
                    .foregroundColor(Color.blue)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            VStack(spacing: 2) {
                Text("Costo")
                    .font(.custom("Artifika-Regular", size: 13))
                    .foregroundColor(Color.primary)
                Text(cost)
                    .font(.custom("Artifika-Regular", size: 16))
                    .foregroundColor(Color.red)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            VStack(spacing: 2) {
                Text("Ganancia")
                    .font(.custom("Artifika-Regular", size: 13))
                    .foregroundColor(Color.primary)
                Text(revenue)
                    .font(.custom("Artifika-Regular", size: 16))
                    .foregroundColor(Color.black)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 2)
        .padding(.bottom, 5)
        .background(Color.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

#Preview {
    SalesSafeAreaBar(sales: "0", cost: "0", revenue: "0")
}
