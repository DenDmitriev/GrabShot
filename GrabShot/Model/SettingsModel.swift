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
    
    func updateOpenDirToggle(value: Bool) {
        session.openDirToggle = value
        userDefaults.saveOpenDirToggle(value)
    }
    
    func updateCreateStripToggle(value: Bool) {
        session.createStrip = value
        userDefaults.saveCreateStrip(value)
    }
    
    func updateStripResolution(_ size: CGSize) {
        session.stripSize = size
        userDefaults.saveStripSize(size)
    }
    
    func updateQuality(_ quality: Double) {
        session.quality = quality
        userDefaults.saveQuality(quality)
    }
    
    func updateStripCount(_ count: Int) {
        session.stripCount = count
        session.userDefaults.saveStripCount(count)
    }
}
