//
//  WindowGroupExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

extension WindowGroup {
    init<W: Identifiable, C: View>(_ titleKey: LocalizedStringKey, uniqueWindow: W, @ViewBuilder content: @escaping () -> C)
    where W.ID == String, Content == PresentedWindowContent<String, C> {
        self.init(titleKey, id: uniqueWindow.id, for: String.self) { _ in
            content()
        } defaultValue: {
            uniqueWindow.id
        }
    }
}
