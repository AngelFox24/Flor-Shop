import SwiftUI

extension View {
    func showProgress(_ isPresented: Bool) -> some View {
        self.overlay {
            if isPresented {
                LoadingView()
            }
        }
    }
}
