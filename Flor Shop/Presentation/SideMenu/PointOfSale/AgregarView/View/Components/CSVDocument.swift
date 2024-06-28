//
//  CSVDocument.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 28/06/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }
    
    var fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    init(configuration: ReadConfiguration) throws {
        // Inicializar con un archivo vacío
        self.fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("csv")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Leer el contenido del archivo para guardarlo
        let data = try Data(contentsOf: fileURL)
        return FileWrapper(regularFileWithContents: data)
    }
}
