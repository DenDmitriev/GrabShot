//
//  ShowVideoImporter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2023.
//

import SwiftUI

struct ShowVideoImporter: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var showVideoImporter: ShowVideoImporter.Value? {
        get { self[ShowVideoImporter.self] }
        set { self[ShowVideoImporter.self] = newValue }
    }
}
