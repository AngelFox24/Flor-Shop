import AppRouter

enum SheetRoutes: SheetType {
    case payment
    case popoverAddView
    
    var id: Int { hashValue }
}
