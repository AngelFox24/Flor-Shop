struct SyncWebSocketClientFactory {
    static func getWebSocketClient(sessionContainer: SessionContainer) -> SyncWebSocketClient {
        let useCase = getSynchronizerUseCase(sessionContainer: sessionContainer)
        let tokens = useCase.getLastToken()
        return SyncWebSocketClient(
            synchronizerDBUseCase: useCase,
            lastTokenByEntities: tokens
        )
    }
    //UseCases
    static private func getSynchronizerUseCase(sessionContainer: SessionContainer) -> SynchronizerDBUseCase {
        return SynchronizerDBInteractor(
            persistentContainer: FlorShopCoreDBProvider.shared.persistContainer,
            companyRepository: sessionContainer.companyRepository,
            subsidiaryRepository: sessionContainer.subsidiaryRepository,
            customerRepository: sessionContainer.customerRepository,
            employeeRepository: sessionContainer.employeeRepository,
            productRepository: sessionContainer.productRepository,
            saleRepository: sessionContainer.salesRepository,
            productSubsidiaryRepository: sessionContainer.productSubsidiaryRepository,
            employeeSubsidiaryRepository: sessionContainer.employeeSubsidiaryRepository,
            syncRepository: sessionContainer.syncRepository
        )
    }
}
