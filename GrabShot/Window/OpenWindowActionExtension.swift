//
//  OpenWindowActionExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

extension OpenWindowAction {
    func callAsFunction<W: Identifiable>(_ window: W) where W.ID == String {
        self.callAsFunction(id: window.id, value: window.id)
    }
}
