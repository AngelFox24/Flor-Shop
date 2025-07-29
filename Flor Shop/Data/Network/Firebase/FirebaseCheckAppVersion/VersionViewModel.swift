import Foundation
//import Firebase
//import FirebaseDatabase

@Observable
class VersionViewModel {
    var isSupported: Bool = true
    var versionState: VersionResult = .loading
    enum VersionResult {
        case loading
        case lockVersion
    }
//    func checkAppVersion() {
//        var minimumVersionApp: String = ""
//        var currentVersionApp: String = ""
//        guard let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
//              let plistData = FileManager.default.contents(atPath: plistPath),
//              let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
//              let currentVersion = plist["CFBundleShortVersionString"] as? String else {
//            print("VersionLocal1: \(currentVersionApp) and MinimunVersion: \(minimumVersionApp)")
//            self.versionState = .lockVersion
//            self.isSupported = false
//            return
//        }
//        currentVersionApp = currentVersion
//        let database = Database.database().reference()
//        let versionRef = database
//        versionRef.observeSingleEvent(of: .value) { snapshot in
//            print("Murio 1")
//            if let versionData = snapshot.value as? [String: Any],
//               let minimumVersion = versionData["MinimalVersion"] as? String {
//                print("Murio 2")
//                minimumVersionApp = minimumVersion
//                print("VersionLocal2: \(currentVersionApp) and MinimunVersion: \(minimumVersionApp)")
//                if currentVersionApp >= minimumVersionApp {
//                    // 1.0.10.345
//                    self.isSupported = true
//                } else {
//                    self.versionState = .lockVersion
//                    self.isSupported = false
//                }
//            } else {
//                self.versionState = .lockVersion
//                self.isSupported = false
//            }
//        }
//        print("VersionLocal3: \(currentVersionApp) and MinimunVersion: \(minimumVersionApp)")
//    }
}
