//
//  Session.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 19.11.2022.
//

import SwiftUI
import Combine

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
    
    @Published var grabCounter: Int
    @Published var showAlertDonate: Bool = false
    
    var stripCount: Int
    var stripSize: CGSize
    var createStrip: Bool
    
    private var store = Set<AnyCancellable>()
    private var backgroundGlobalQueue = DispatchQueue.global(qos: .background)
    
    private init() {
        videos = []
        let userDefaults = UserDefaultsService()
        self.userDefaults = userDefaults
        quality = userDefaults.getQuality()
        period = userDefaults.getPeriod()
        openDirToggle = userDefaults.getOpenDirToggle()
        stripCount = userDefaults.getStripCount()
        stripSize = userDefaults.getStripSize()
        createStrip = userDefaults.getCreateStrip()
        grabCounter = userDefaults.getGrabCount()
        userDefaults.saveFirstInitDate()
        bindGrabCounter()
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
    
    func updateGrabCounter(_ count: Int) {
        grabCounter += count
    }
    
    func syncGrabCounter(_ counter: Int) {
        userDefaults.saveGrabCount(counter)
        grabCounter = userDefaults.getGrabCount()
    }
    
    private func bindGrabCounter() {
        $grabCounter
            .receive(on: backgroundGlobalQueue)
            .sink { [weak self] counter in
                if GrabCounter.trigger(counter: counter) {
                    sleep(GrabCounter.triggerSleepSeconds)
                    DispatchQueue.main.async {
                        self?.showAlertDonate = true
                    }
                }
            }
            .store(in: &store)
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
