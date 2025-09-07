import SwiftUI

@ViewBuilder
func view(for destination: PushDestination) -> some View {
    switch destination {
    case .selectCustomer:
        WithSession { ses in
            CustomerSelectionView(ses: ses)
        }
    case .editCustomer(let customerId):
        WithSession { ses in
            EditCustomerView(ses: ses, customerId: customerId)
        }
    case .addCustomer:
        WithSession { ses in
            AddCustomerView(ses: ses)
        }
    case .customerHistory(let customerId):
        WithSession { ses in
            CustomerHistoryView(ses: ses, customerId: customerId)
        }
    case .payment:
        WithSession { ses in
            PaymentView(ses: ses)
        }
    case .cartList:
        WithSession { ses in
            CartView(ses: ses)
        }
    case .editProduct(let productId):
        WithSession { ses in
            EditProductView(ses: ses, productId: productId)
        }
    case .addProduct:
        WithSession { ses in
            AddProductView(ses: ses)
        }
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
