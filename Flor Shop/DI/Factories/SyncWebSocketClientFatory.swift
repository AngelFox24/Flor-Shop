struct SyncWebSocketClientFatory {
    static func getProductViewModel(sessionContainer: SessionContainer) -> SyncWebSocketClient {
        let useCase = getProductsUseCase(sessionContainer: sessionContainer)
        let tokens = useCase.getLastToken()
        return SyncWebSocketClient(
            synchronizerDBUseCase: useCase,
            lastTokenByEntities: tokens
        )
    }
    //UseCases
    static private func getProductsUseCase(sessionContainer: SessionContainer) -> SynchronizerDBUseCase {
        return SynchronizerDBInteractor(
            persistentContainer: CoreDataProvider.shared.persistContainer,
            imageRepository: sessionContainer.imageRepository,
            companyRepository: sessionContainer.companyRepository,
            subsidiaryRepository: sessionContainer.subsidiaryRepository,
            customerRepository: sessionContainer.customerRepository,
            employeeRepository: sessionContainer.employeeRepository,
            productRepository: sessionContainer.productRepository,
            saleRepository: sessionContainer.salesRepository,
            syncRepository: sessionContainer.syncRepository
        )
    }
}
