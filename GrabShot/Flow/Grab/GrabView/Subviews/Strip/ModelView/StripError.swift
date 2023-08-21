//
//  StripError.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.08.2023.
//

import Foundation

enum StripError: Error {
case create(localizedDescription: String)
}

extension StripError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .create(let localizedDescription):
            return localizedDescription
        }
    }
}
