//
//  LocalStorageError.swift
//  Flor Shop
//
//  Created by Angel Curi Laurente on 13/07/2024.
//

import Foundation

enum LocalStorageError: LocalizedError {
    case syncFailed(String)
    case entityNotFound(String)  // Cuando la entidad solicitada no se encuentra en el modelo de datos
    case saveFailed(String)  // Cuando no se puede guardar el contexto de Core Data
    case fileSaveFailed(String)  // Cuando no se puede guardar un archivo en el sistema de archivos
    case fetchFailed(String)  // Cuando la consulta de datos falla
    case invalidInput(String)  // Cuando los datos de entrada no son correctos
//    case deleteFailed(String)  // Cuando la eliminación de un objeto falla
//    case contextUnavailable(String)  // Cuando no se puede acceder al contexto de Core Data
//    case invalidManagedObject(String)  // Cuando el Managed Object es inválido o no se puede usar
//    case migrationFailed(String)  // Cuando falla una migración del modelo de datos
//    case persistentStoreUnavailable(String)  // Cuando la tienda persistente no está disponible o no se puede acceder a ella
//    case batchUpdateFailed(String)  // Cuando una operación de actualización por lotes falla
//    case batchDeleteFailed(String)  // Cuando una operación de eliminación por lotes falla

    var errorDescription: String? {
        switch self {
        case .syncFailed(let message),
                .entityNotFound(let message),
                .saveFailed(let message),
                .fileSaveFailed(let message),
                .fetchFailed(let message),
                .invalidInput(let message):
//             .deleteFailed(let message),
//             .contextUnavailable(let message),
//             .invalidManagedObject(let message),
//             .migrationFailed(let message),
//             .persistentStoreUnavailable(let message),
//             .batchUpdateFailed(let message),
//             .batchDeleteFailed(let message):
            return message
        }
    }
}
