//
//  LocalStorageError.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

enum LocalStorageError: Error {
    case notFound(String)
    case unknownError(statusCode: Int)
}
