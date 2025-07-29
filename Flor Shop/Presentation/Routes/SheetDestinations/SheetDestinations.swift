import SwiftUI

extension View {
    func withSheetDestinations(router: Binding<Router>) -> some View {
        modifier(
            SheetDestinations(
                router: router
            )
        )
    }
}

public struct SheetDestinations: ViewModifier {
    @Binding var router: Router
    public func body(content: Content) -> some View {
        content.sheet(item: $router.presentedSheet) { sheetItem in
            switch sheetItem {
            case .payment:
                PaymentView()
            case .popoverAddView:
                PopoverHelpAddView()
            }
        }
    }
}
