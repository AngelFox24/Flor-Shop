import SwiftUI

extension View {
  func withFlowDestinations() -> some View {
      modifier(Flows())
  }
}

struct Flows: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: FlowRoutes.self) { flow in
                switch flow {
                case .logInFlow(let subFlow):
                    SessionFlow.getView(subFlow)
                case .pointOfSale:
//                    SessionFlow.getView(.loginView)
                    Text("Point of sale")
                }
            }
    }
}
