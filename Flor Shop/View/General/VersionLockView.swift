//
//  VersionLockView.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 7/07/23.
//

import SwiftUI

struct VersionLockView: View {
    var textito:String
    var body: some View {
        Text(textito)
    }
}

struct VersionLockView_Previews: PreviewProvider {
    static var previews: some View {
        VersionLockView(textito: "Cargando")
    }
}
