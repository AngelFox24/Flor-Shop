import Foundation

enum Destination: Hashable {
    case tab(_ destination: TabDestination)
    case push(_ destination: PushDestination)
    case sheet(_ destination: SheetDestination)
    case fullScreen(_ destination: FullScreenDestination)
}

extension Destination: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .tab(destination): ".tab(\(destination))"
        case let .push(destination): ".push(\(destination))"
        case let .sheet(destination): ".sheet(\(destination))"
        case let .fullScreen(destination): ".fullScreen(\(destination))"
        }
    }
}

public enum TabDestination: String, Hashable {
    case pointOfSale
    case sales
    case customers
    case employees
    case settings
}

enum PushDestination: Hashable, CustomStringConvertible {
    //CustomerList for selection in payment flow
    case selectCustomer
    case editCustomer(customerCic: String)
    case addCustomer
    case customerHistory(customerCic: String)
    case payment
    case cartList
    case editProduct(productCic: String)
    case addProduct
    case addEmployee
    case payCustomerTotalDebd(customerCic: String)

    var description: String {
        switch self {
//        case .customerView(let parameters): ".customerView(\(parameters))"
        case .selectCustomer: ".selectCustomer"
        case .editCustomer(let customerId): ".editCustomer(\(String(describing: customerId)))"
        case .addCustomer: ".addCustomer"
        case .customerHistory: ".customerHistory"
        case .payment: ".payment"
        case .cartList: ".cartList"
        case .editProduct(let productId): ".editProduct(\(String(describing: productId)))"
        case .addProduct: ".addProduct"
        case .addEmployee: ".addEmployee"
        case .payCustomerTotalDebd(let customerCic): ".payCustomerTotalDebd(\(String(describing: customerCic)))"
        }
    }
}

public struct BarcodeAction: Equatable, Hashable {
    let id: UUID = UUID()
    let action: (String) -> Void
    public static func == (lhs: BarcodeAction, rhs: BarcodeAction) -> Bool {
        lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum SheetDestination: Hashable, CustomStringConvertible {
//    case movieDescription(id: MovieID)
//    case movieDescriptionValue(id: MovieID, title: String, description: String)
    case barcodeScanner(action: BarcodeAction)

    public var description: String {
        switch self {
//        case let .movieDescription(id): ".movieDescription(\(id))"
//        case let .movieDescriptionValue(id, _, _): ".movieDescriptionValue(\(id))"
        case .barcodeScanner: ".barcodeScanner"
        }
    }
}

extension SheetDestination: Identifiable {
    public var id: String {
        switch self {
//        case let .movieDescription(id): id.rawValue.formatted()
//        case let .movieDescriptionValue(id, _, _): id.rawValue.formatted()
            case .barcodeScanner: "barcodeScanner"
        }
    }
}

public enum FullScreenDestination: Hashable {
    // `movieGallery` and `movieGalleryValue` are the same, but they represent
    // different data states, for the first one, we need to fetch the data, but
    // on the second one the data is already available.
    //
    // The first one is intended for deep linking
    // The second one is intended for in-app navigation, as the data is already available
    // when we will show the movie gallery
//    case movieGallery(id: MovieID)
//    case movieGalleryValue(id: MovieID, images: [MovieDetails.ImageCollection.Backdrop], selectedImageIndex: Int)
//    case editAmount
    case completeEmployeeProfile
}

extension FullScreenDestination: CustomStringConvertible {
    public var description: String {
        switch self {
//        case let .movieGallery(id): ".movieGallery(\(id))"
//        case let .movieGalleryValue(id, _, _): ".movieGalleryValue(\(id))"
//        case .editAmount: ".editAmount"
        case .completeEmployeeProfile: ".completeEmployeeProfile"
        }
    }
}

extension FullScreenDestination: Identifiable {
    public var id: String {
        switch self {
//        case let .movieGallery(id): id.rawValue.formatted()
//        case let .movieGalleryValue(id, _, _): id.rawValue.formatted()
//        case .editAmount: "editAmount"
        case .completeEmployeeProfile: "completeEmployeeProfile"
        }
    }
}
