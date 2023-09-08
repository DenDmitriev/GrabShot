//
//  SettingsModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

class SettingsModel: ObservableObject {
    
    private let userDefaults: UserDefaultsService
    var videoStore: VideoStore
    
    init() {
        self.videoStore = VideoStore.shared
        self.userDefaults = UserDefaultsService()
    }
    
    func updateCreateStripToggle(value: Bool) {
        videoStore.createStrip = value
    }
}
