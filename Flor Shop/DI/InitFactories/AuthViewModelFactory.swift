import Foundation
final class AuthViewModelFactory {
    let container: SoftDIContainer
    
    init(container: SoftDIContainer) {
        self.container = container
    }
    
    func makeLogInViewModel() -> LogInViewModel {
        LogInViewModel(
            logInUseCase: container.logInUseCase,
            logOutUseCase: container.logOutUseCase
        )
    }
    
    func makeRegisterViewModel() -> RegistrationViewModel {
        RegistrationViewModel(
            registerUseCase: container.registerUseCase
        )
    }
}
