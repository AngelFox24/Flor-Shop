import Foundation

struct SalesViewModelFactory {
    static func getSalesViewModel(sessionContainer: SessionContainer) -> SalesViewModel {
        return SalesViewModel(
            registerSaleUseCase: getRegisterSaleUseCase(sessionContainer: sessionContainer),
            getSalesUseCase: getSalesUseCase(sessionContainer: sessionContainer),
            getSalesDetailsUseCase: getSalesDetailsUseCase(sessionContainer: sessionContainer)
        )
    }
    static private func getRegisterSaleUseCase(sessionContainer: SessionContainer) -> RegisterSaleUseCase {
        return RegisterSaleInteractor(saleRepository: sessionContainer.salesRepository)
    }
    static private func getSalesUseCase(sessionContainer: SessionContainer) -> GetSalesUseCase {
        return GetSalesInteractor(saleRepository: sessionContainer.salesRepository)
    }
    static private func getSalesDetailsUseCase(sessionContainer: SessionContainer) -> GetSalesDetailsUseCase {
        return GetSalesDetailsInteractor(saleRepository: sessionContainer.salesRepository)
    }
}
