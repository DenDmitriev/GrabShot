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
    @Published var period: Int {
        didSet {
            userDefaults.savePeriod(period)
        }
    }
    @Published var quality: Double {
        didSet {
            userDefaults.saveQuality(quality)
        }
    }
    @Published var isCalculating: Bool = false
    @Published var isGrabbing: Bool = false
    
    var selectedTab: TabApp.ID
    @Published var openDirToggle: Bool
    var stripCount: Int
    var stripSize: CGSize
    var createStrip: Bool
    
    private init() {
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
    
    func addVideo(video: Video) async throws {
        await MainActor.run {
            isCalculating = true
        }
        
        let duration = try await getDuration(video)
        video.duration = duration
        
        await MainActor.run {
            isCalculating = false
            videos.append(video)
        }
    }
    
    private func getDuration(_ video: Video) async throws -> TimeInterval {
        let duration = try await VideoService.duration(for: video)
        return duration
    }
}
