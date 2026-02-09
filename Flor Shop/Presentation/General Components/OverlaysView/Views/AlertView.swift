import SwiftUI

struct ConfirmAction: Equatable {
    let title: String
    let action: () -> Void
    
    static func == (lhs: ConfirmAction, rhs: ConfirmAction) -> Bool {
        return lhs.title == rhs.title
    }
}

struct AlertView: View {
    let message: String
    let primaryAction: ConfirmAction
    var body: some View {
        VStack {
            HStack {
                Text("Error")
                    .font(.title2)
                Spacer()
                Button {
                    primaryAction.action()
                } label: {
                    Image(systemName: "checkmark")
                        .frame(width: 18, height: 28)
                }
                .buttonStyle(.glassProminent)
            }
            Text(message)
        }
        .padding()
        .background(Color.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(50)
    }
}

#Preview {
    AlertView(message: "Ha ocurrido una alerta", primaryAction: .init(title: "OK", action: {}))
}
