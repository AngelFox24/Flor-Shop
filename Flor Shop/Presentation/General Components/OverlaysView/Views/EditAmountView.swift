import SwiftUI
import FlorShopDTOs

struct EditAction: Equatable {
    let title: String
    let action: (Int)-> Void
    
    static func == (lhs: EditAction, rhs: EditAction) -> Bool {
        return lhs.title == rhs.title
    }
}

struct EditAmountView: View {
    let imageUrl: String?
    let confirm: EditAction
    let type: UnitType
    @State var amount: Int = 0
    init(
        imageUrl: String?,
        confirm: EditAction,
        type: UnitType,
        initialAmount: Int
    ) {
        self.imageUrl = imageUrl
        self.confirm = confirm
        self.type = type
        self._amount = State(initialValue: initialAmount)
    }
    var body: some View {
        VStack {
            HStack {
                Spacer()
                HStack {
                    Text(confirm.title)
                        .font(.title2)
                    Spacer()
                    Button {
                        confirm.action(amount)
                    } label: {
                        Image(systemName: "checkmark")
                            .frame(width: 18, height: 28)
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            HStack {
                CustomAsyncImageView(imageUrlString: imageUrl, size: 80)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                CustomNumberField(
                    title: "Cantidad",
                    userInput: $amount,
                    edited: .constant(true),
                    numberOfDecimals: type == .kilo ? 3 : 0
                )
            }

        }
        .padding()
        .background(Color.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(50)
    }
}

#Preview {
    EditAmountView(
        imageUrl: "https://mercafreshperu.com/wp-content/uploads/2024/02/papa-criolla-amarilla.webp",
        confirm: EditAction(title: "Papas", action: {_ in }),
        type: .kilo,
        initialAmount: 12
    )
}
