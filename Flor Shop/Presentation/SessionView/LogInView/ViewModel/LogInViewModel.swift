import Foundation

enum LogInStatus {
    case success
    case fail
}
@Observable
class LogInViewModel {
    //MARK: LogInFields
    var errorLogIn: String = ""
//    func logIn() async throws -> SessionConfig {
//        return try await self.logInUseCase.execute(
//            username: userOrEmail,
//            password: password
//        )
//    }
//    func logOut() {
//        self.logOutUseCase.execute()
//    }
}

//struct LogInFields {
//    var userOrEmail: String = "angel.curi"
//    var userOrEmailEdited: Bool = false
//    var userOrEmailError: String {
//        if userOrEmail == "" && userOrEmailEdited {
//            return "Nombre de producto no válido"
//        } else {
//            return ""
//        }
//    }
//    var password: String = "asd"
//    var passwordEdited: Bool = false
//    var passwordError: String {
//        if self.password == "" && self.passwordEdited {
//            return "Contraseña no válido"
//        } else {
//            return ""
//        }
//    }
//    var errorLogIn: String = ""
//}
