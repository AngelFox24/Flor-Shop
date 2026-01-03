import SwiftUI

/// My own version of `NavigationLink` to work with the ``Router``
struct NavigationBasicButton: View {
    let destination: Destination
    let systemImage: String
    @Environment(FlorShopRouter.self) private var router

    init(
        destination: Destination,
        systemImage: String
    ) {
        self.destination = destination
        self.systemImage = systemImage
    }

    init(
        push destination: PushDestination,
        systemImage: String
    ) {
        self.destination = .push(destination)
        self.systemImage = systemImage
    }

    init(
        sheet destination: SheetDestination,
        systemImage: String
    ) {
        self.destination = .sheet(destination)
        self.systemImage = systemImage
    }

    init(
        fullScreen destination: FullScreenDestination,
        systemImage: String
    ) {
        self.destination = .fullScreen(destination)
        self.systemImage = systemImage
    }

    var body: some View {
        Button("Done", systemImage: systemImage, action: { router.navigate(to: destination) })
    }
}
