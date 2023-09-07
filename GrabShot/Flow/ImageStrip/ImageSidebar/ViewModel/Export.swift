//
//  Export.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 07.09.2023.
//

import Foundation

enum Export {
    case all, selected, context(id: UUID)
}
