import Foundation

@Observable
class FirebaseSesionManagement {
    var sesionState = false
    
    func logIn(user: String, password: String) {
        if user != "" && password != "" {
            sesionState = true
        }
    }
}
