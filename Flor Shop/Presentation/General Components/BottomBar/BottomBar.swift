import SwiftUI

struct BottomBar: View {
    @Binding var findText: String
    @State var isSearchExpanded: Bool = false
    @FocusState var isInputActive: Bool
    let pushDestination: PushDestination
    init(findText: Binding<String>, addDestination: PushDestination) {
        self._findText = findText
        self.pushDestination = addDestination
    }
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            HStack {
                if !isSearchExpanded {
                    NavigationButton(push: pushDestination) {
                        Image(systemName: "plus")
                            .font(.custom("Artifika-Regular", size: 30))
                            .foregroundColor(Color.white)
                            .frame(width: 50, height: 50)
                            .background(Color.primary)
                            .cornerRadius(30)
                    }
                    Spacer()
                }
                HStack(spacing: 0) {
                    Button {
                        withAnimation(.bouncy) {
                            isSearchExpanded = true
                            isInputActive = true
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.custom("Artifika-Regular", size: isSearchExpanded ? 25 : 30))
                            .foregroundColor(isSearchExpanded ? Color.primary : Color.white)
                            .padding(10)
                    }.disabled(isSearchExpanded ? true : false)

                    if isSearchExpanded {
                        TextField("", text: $findText)
                            .focused($isInputActive)
                            .padding(.vertical, 14)
                            .font(.custom("Artifika-Regular", size: 16))
                            .foregroundColor(Color.primary)
                            .submitLabel(.done)
                            .disableAutocorrection(true)
                        Button {
                            findText = ""
                            withAnimation(.bouncy) {
                                isInputActive = false
                                isSearchExpanded = false
                            }
                        } label: {
                            Image(systemName: "x.circle")
                                .foregroundColor(Color.primary)
                                .font(.custom("Artifika-Regular", size: 20))
                                .padding(10)
                        }
                    }
                }
                .frame(width: isSearchExpanded ? size.width : 50)
                .background(isSearchExpanded ? Color.white : Color.primary)
                .clipShape (
                    RoundedRectangle(cornerRadius: 25)
                )
            }
        }
        .frame(height: 50)
    }
}

#Preview {
    @Previewable @State var findText: String = ""
    let router = FlorShopRouter.previewRouter()
    VStack(spacing: 0) {
        Spacer()
        BottomBar(findText: $findText, addDestination: .addCustomer)
            .environment(router)
    }
    .background(Color.background)
}
