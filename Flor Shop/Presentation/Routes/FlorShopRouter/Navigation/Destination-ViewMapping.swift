import SwiftUI

@ViewBuilder
func view(for destination: PushDestination) -> some View {
    @Environment(SessionContainer.self) var ses
    switch destination {
    case .selectCustomer:
        CustomerSelectionView(ses: ses)
    case .editCustomer(let customerId):
        EditCustomerView(ses: ses, customerId: customerId)
    case .addCustomer:
        AddCustomerView(ses: ses)
    case .customerHistory(let customerId):
        CustomerHistoryView(ses: ses, customerId: customerId)
    case .payment:
        PaymentView(ses: ses)
    case .cartList:
        CartView(ses: ses)
    case .editProduct(let productId):
        EditProductView(ses: ses, productId: productId)
    case .addProduct:
        AddProductView(ses: ses)
    }
}

@ViewBuilder
func view(for destination: SheetDestination) -> some View {
    Text("Not implemented")
//    Group {
//        switch destination {
//        case let .movieDescription(id):
//            MovieDescriptionScreen(movieID: id)
//
//        case let .movieDescriptionValue(id, title, description):
//            MovieDescriptionScreen(movieID: id, title: title, description: description)
//        }
//    }
//    .navigationBarTitleDisplayMode(.inline)
//    .addDismissButton()
//    .presentationDetents([.medium, .large])
//    .presentationBackground(.regularMaterial)
}

@ViewBuilder
func view(for destination: FullScreenDestination) -> some View {
    Text("Not implemented")
//    Group {
//        switch destination {
//        case let .movieGallery(id):
//            MovieImageGalleryScreen(movieID: id)
//
//        case let .movieGalleryValue(id, images, selectedImageIndex):
//            MovieImageGalleryScreen(movieID: id, images: images, selectedImage: selectedImageIndex)
//        }
//    }
//    .addDismissButton()
//    .presentationBackground(.black)
}
