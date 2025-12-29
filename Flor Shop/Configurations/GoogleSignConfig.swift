import GoogleSignIn
import GoogleSignInSwift

enum GoogleSignConfig {
    static func config() {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
              let serverClientID = Bundle.main.object(forInfoDictionaryKey: "GIDServerClientID") as? String
        else {
            fatalError("Google Client IDs missing in Info.plist")
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: clientID,
            serverClientID: serverClientID
        )
    }
}
