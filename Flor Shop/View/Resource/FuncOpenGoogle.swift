//
//  FuncOpenGoogle.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 19/08/23.
//

import SwiftUI
import SafariServices

func openGoogleImageSearch(nombre: String) {
    // Limpia la cadena de búsqueda para que sea válida en una URL
    guard let cleanedSearchQuery = nombre.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let googleImageSearchURL = URL(string: "https://www.google.com/search?tbm=isch&q=\(cleanedSearchQuery)") else {
        return
    }
    
    // Abre la URL en Safari mediante SFSafariViewController
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let topViewController = windowScene.windows.first?.rootViewController {
        let safariViewController = SFSafariViewController(url: googleImageSearchURL)
        topViewController.present(safariViewController, animated: true, completion: nil)
    }
}

func pasteFromClipboard() -> String {
    if let clipboardContent = UIPasteboard.general.string {
        return clipboardContent
    } else {
        return ""
    }
}
