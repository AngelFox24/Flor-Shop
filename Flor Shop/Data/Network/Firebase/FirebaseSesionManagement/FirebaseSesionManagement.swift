import Foundation

class FirebaseSesionManagement: ObservableObject {
    @Published var sesionState = false
    
    func logIn(user: String, password: String) {
        if user != "" && password != "" {
            sesionState = true
        }
    }
}
