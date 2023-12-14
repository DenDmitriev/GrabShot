//
//  ShowRangePicker.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 13.12.2023.
//

import SwiftUI

struct ShowRangePicker: FocusedValueKey {
    typealias Value = Binding<Bool>
    var video: Video?
}
extension FocusedValues {
    var showRangePicker: Binding<Bool>? {
        get { self[ShowRangePicker.self] }
        set { self[ShowRangePicker.self] = newValue }
    }
}
