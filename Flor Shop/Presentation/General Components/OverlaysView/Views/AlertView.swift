//
//  LoadingView.swift
//  TestLoadingScreens
//
//  Created by Angel Curi Laurente on 24/12/2025.
//

import SwiftUI

struct AlertAction: Equatable {
    let title: String
    let action: () -> Void
    
    static func == (lhs: AlertAction, rhs: AlertAction) -> Bool {
        return lhs.title == rhs.title
    }
}

struct AlertView: View {
    let message: String
    let primaryAction: AlertAction
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.bubble.fill")
                Text("Alerta")
            }
            Text(message)
            Button {
                primaryAction.action()
            } label: {
                Text(primaryAction.title)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }

        }
        .padding()
        .background(Color.green.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    AlertView(message: "Ha ocurrido una alerta", primaryAction: .init(title: "OK", action: {}))
}
