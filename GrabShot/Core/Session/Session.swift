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
    @Published var openDirToggle: Bool
    
    @Published var error: GrabShotError?
    @Published var showAlert = false
    
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
        self.stripSize = userDefaults.getStripSize()
        self.createStrip = userDefaults.getCreateStrip()
    }
    
    func addVideo(video: Video) {
        self.videos.append(video)
        DispatchQueue.global(qos: .utility).async {
            self.getDuration(video)
        }
    }
    
    func presentError(error: LocalizedError) {
        let error = GrabShotError.map(errorDescription: error.errorDescription, recoverySuggestion: error.recoverySuggestion)
        DispatchQueue.main.async {
            self.error = error
            self.showAlert = true
        }
    }
    
    private func getDuration(_ video: Video) {
        DispatchQueue.main.async {
            self.isCalculating = true
        }
        
        VideoService.duration(for: video) { result in
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    video.duration = success
                    self.isCalculating = false
                }
            case .failure(let failure):
                DispatchQueue.main.async {
                    self.error = .map(errorDescription: failure.localizedDescription, recoverySuggestion: nil)
                    self.showAlert = true
                    self.isCalculating = false
                }
            }
        }
    }
}
