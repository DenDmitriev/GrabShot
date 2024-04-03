//
//  ProgressKey.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.02.2024.
//

import SwiftUI

private struct ProgressKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isProgress: Binding<Bool> {
        get { self[ProgressKey.self] }
        set { self[ProgressKey.self] = newValue }
    }
}
