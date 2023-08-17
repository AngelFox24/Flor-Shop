//
//  FirebaseSesionManagement.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 14/08/23.
//

import Foundation

class FirebaseSesionManagement ObservableObject {
    @Published sesionState = false
    
    func logIn(user: String, password: String) {
        if user != "" && password != "" {
            sesionState = true
        }
    }
}
