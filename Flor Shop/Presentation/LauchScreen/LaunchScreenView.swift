import SwiftUI

struct LaunchScreenView: View {
    @State private var firstPhaseIsAnimating: Bool = false
    @State private var rotationAngle: Angle = .zero
    private let timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color.launchBackground
                .edgesIgnoringSafeArea(.all)
            Image("logo")
                .scaleEffect(firstPhaseIsAnimating ? 0.8 : 1)
                .rotationEffect(rotationAngle)
        }
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
struct LoadingView: View {
    @State private var firstPhaseIsAnimating: Bool = false
    @State private var rotationAngle: Angle = .zero
    private let timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            Color.launchBackground
                .edgesIgnoringSafeArea(.all)
                .opacity(0.5)
                .disabled(true)
            Image("logo")
                .scaleEffect(firstPhaseIsAnimating ? 0.8 : 1)
                .rotationEffect(rotationAngle)
        }
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
struct LoadingFotoView: View {
    @State private var firstPhaseIsAnimating: Bool = false
    @State private var rotationAngle: Angle = .zero
    private let timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()
    var size: CGFloat = 105
    var body: some View {
        VStack(spacing: 0, content: {
            ZStack {
                Color.launchBackground
                    .opacity(0.8)
                Image("logo")
                    .resizable()
                    .scaleEffect(firstPhaseIsAnimating ? 0.8 : 1)
                    .rotationEffect(rotationAngle)
            }
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
        })
        .frame(width: size, height: size)
    }
}
struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            LaunchScreenView()
        }
    }
}
