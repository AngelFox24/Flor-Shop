import SwiftUI

struct CustomSearchField: View {
    let placeHolder: String = "Buscar"
    @FocusState var isInputActive: Bool
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("color_accent"))
                .font(.custom("Artifika-Regular", size: 16))
                .padding(.vertical, 10)
                .padding(.leading, 10)
            TextField(placeHolder, text: $text)
                .focused($isInputActive)
                .padding(.vertical, 10)
                .font(.custom("Artifika-Regular", size: 16))
                .foregroundColor(Color("color_primary"))
                .submitLabel(.done)
                .disableAutocorrection(true)
            Button(action: {
                text = ""
            }, label: {
                Image(systemName: "x.circle")
                    .foregroundColor(Color("color_accent"))
                    .font(.custom("Artifika-Regular", size: 16))
                    .padding(.vertical, 10)
                    .padding(.trailing, 10)
            })
        }
        .background(.white)
        .cornerRadius(20.0)
    }
}
