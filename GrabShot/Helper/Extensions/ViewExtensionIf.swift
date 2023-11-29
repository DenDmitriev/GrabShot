//
//  ViewExtensionIf.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.11.2023.
//

import SwiftUI

extension View {
    func ifTrue(_ condition:Bool, apply:(AnyView) -> (AnyView)) -> AnyView {
        if condition {
            return apply(AnyView(self))
        }
        else {
            return AnyView(self)
        }
    }
}

