//
//  SettingsModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

class SettingsModel: ObservableObject {
    
    private let userDefaults: UserDefaultsService = .default
    
    func updateCreateStripToggle(value: Bool) {
        UserDefaultsService.default.createStrip = value
    }
}
