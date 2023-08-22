//
//  SettingsModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

class SettingsModel: ObservableObject {
    
    private let userDefaults: UserDefaultsService
    var session: Session
    
    init() {
        self.session = Session.shared
        self.userDefaults = UserDefaultsService()
    }
    
    func updateCreateStripToggle(value: Bool) {
        session.createStrip = value
    }
}
