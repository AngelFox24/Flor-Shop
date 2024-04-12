//
//  LaunchScreenView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 8/07/23.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var firstPhaseIsAnimating: Bool = false
    @State private var rotationAngle: Angle = .zero
    private let timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color("colorlaunchbackground")
                .edgesIgnoringSafeArea(.all)
            Image("logo")
                .scaleEffect(firstPhaseIsAnimating ? 0.8 : 1)
                .rotationEffect(rotationAngle)
        }
        .onReceive(timer) { _ in
            // First phase with continuos scaling
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
struct LoadingView: View {
    @State private var firstPhaseIsAnimating: Bool = false
    @State private var rotationAngle: Angle = .zero
    private let timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color("colorlaunchbackground")
                .edgesIgnoringSafeArea(.all)
                .opacity(0.5)
            Image("logo")
                .scaleEffect(firstPhaseIsAnimating ? 0.8 : 1)
                .rotationEffect(rotationAngle)
        }
        .onReceive(timer) { _ in
            // First phase with continuos scaling
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
struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
