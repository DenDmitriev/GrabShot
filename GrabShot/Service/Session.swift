//
//  Session.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 19.11.2022.
//

import SwiftUI

class Session: ObservableObject {
    
    static let shared = Session()
    
    let userDefaults: UserDefaultsService
    
    @Published var videos: [Video]
    @Published var period: Int
    @Published var quality: Double
    
    var selectedTab: TabApp.ID
    var openDirToggle: Bool
    var stripCount: Int
    var stripSize: CGSize
    //var shotSize: CGSize
    var createStrip: Bool
    
    init() {
        self.videos = []
        let userDefaults = UserDefaultsService()
        self.userDefaults = userDefaults
        self.quality = userDefaults.getQuality()
        self.period = userDefaults.getPeriod()
        self.openDirToggle = userDefaults.getOpenDirToggle()
        self.stripCount = userDefaults.getStripCount()
        self.selectedTab = TabApp.dropTab.id
        self.stripSize = userDefaults.getStripSize()
        self.createStrip = userDefaults.getCreateStrip()
    }
}
