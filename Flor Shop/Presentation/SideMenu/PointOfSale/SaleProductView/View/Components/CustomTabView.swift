import SwiftUI

struct CustomTabView: View {
    var body: some View {
        HStack {
            NavigationButton(push: .addCustomer) {
                Image(systemName: "plus")
                    .font(.custom("Artifika-Regular", size: 30))
                    .foregroundColor(Color.white)
                    .frame(width: 50, height: 50)
                    .background(Color.primary)
                    .cornerRadius(30)
            }
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.custom("Artifika-Regular", size: 30))
                .foregroundColor(Color.white)
                .frame(width: 50, height: 50)
                .background(Color.primary)
                .cornerRadius(30)
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    CustomTabView()
}
