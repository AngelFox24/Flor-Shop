//
//  LoadingView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 24/12/2025.
//

import SwiftUI

struct LoadingView: View {
    @State private var firstPhaseIsAnimating: Bool = false
    @State private var rotationAngle: Angle = .zero
    private let timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()
    var body: some View {
        Image("logo")
            .scaleEffect(firstPhaseIsAnimating ? 0.8 : 1)
            .rotationEffect(rotationAngle)
            .onReceive(timer) { _ in
                withAnimation(.spring()) {
                    firstPhaseIsAnimating.toggle()
                }
            }
            .onAppear {
                withAnimation(Animation.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                    rotationAngle = .degrees(-360)
                }
            }
    }
}

#Preview {
    LoadingView()
}
