//
//  ViewExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 11.09.2023.
//

import SwiftUI

extension View {
    @ViewBuilder
    func labelStyle(includingText: Bool) -> some View {
        if includingText {
            self.labelStyle(.titleAndIcon)
        } else {
            self.labelStyle(.iconOnly)
        }
    }
}
