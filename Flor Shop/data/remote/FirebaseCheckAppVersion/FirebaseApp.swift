//
//  FirebaseApp.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import Foundation
import Firebase
import FirebaseDatabase
class VersionCheck: ObservableObject {
    @Published var versionIsOk: VersionResult = .Loading
    enum VersionResult {
        case Loading
        case LockVersion
        case VersionOk
        case Unowned
    }
    func checkAppVersion() {
        var minimumVersionApp: String = ""
        var currentVersionApp: String = ""
        guard let plistPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plist = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
              let currentVersion = plist["CFBundleShortVersionString"] as? String else {
            print ("VersionLocal1: \(currentVersionApp) and MinimunVersion: \(minimumVersionApp)")
            self.versionIsOk = .LockVersion
            return
        }
        
        currentVersionApp = currentVersion
        
        let database = Database.database().reference()
        let versionRef = database
        
        versionRef.observeSingleEvent(of: .value) { snapshot in
            print ("Murio 1")
            if let versionData = snapshot.value as? [String: Any],
               let minimumVersion = versionData["MinimalVersion"] as? String {
                print ("Murio 2")
                minimumVersionApp = minimumVersion
                print ("VersionLocal2: \(currentVersionApp) and MinimunVersion: \(minimumVersionApp)")
                if currentVersionApp >= minimumVersionApp {
                    self.versionIsOk = .VersionOk
                }
                else{
                    self.versionIsOk = .LockVersion
                }
            }
            else {
                self.versionIsOk = .LockVersion
            }
        }
        print ("VersionLocal3: \(currentVersionApp) and MinimunVersion: \(minimumVersionApp)")
    }
}


