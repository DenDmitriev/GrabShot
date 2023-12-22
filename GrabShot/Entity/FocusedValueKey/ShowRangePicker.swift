//
//  ShowRangePicker.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 13.12.2023.
//
// https://www.swiftdevjournal.com/accessing-the-document-in-a-swiftui-menu/

import SwiftUI

struct ShowRangePicker: FocusedValueKey {
    typealias Value = Binding<Bool>
    var video: Video?
}

extension FocusedValues {
    var showRangePicker: ShowRangePicker.Value? {
        get { self[ShowRangePicker.self] }
        set { self[ShowRangePicker.self] = newValue }
    }
}
