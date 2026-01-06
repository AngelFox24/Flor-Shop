import SwiftUI

struct TotalSafeAreaBarView: View {
    let total: String
    var body: some View {
        HStack {
            Text("Total:")
            Spacer()
            Text(String("S/. "))
                .font(.custom("Artifika-Regular", size: 15))
            Text(total)
                .font(.custom("Artifika-Regular", size: 20))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.bottom, 10)
    }
}

#Preview {
    TotalSafeAreaBarView(total: "0")
}
