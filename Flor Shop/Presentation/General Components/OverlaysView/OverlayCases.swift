import FlorShopDTOs

enum OverlayCases: Equatable {
    case loading
    case alert(message: String, primaryAction: ConfirmAction)
    case editAmount(imageUrl: String?, confirm: EditAction, type: UnitType, initialAmount: Int)
}
