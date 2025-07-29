enum FlowRoutes: FlowType {
    case logInFlow(SessionRoutes)
    case pointOfSale
    
    var id: Int { hashValue }
}
