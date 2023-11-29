//
//  Session.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 19.11.2022.
//

import SwiftUI
import Combine

class VideoStore: ObservableObject {
    
    let userDefaults: UserDefaultsService = UserDefaultsService.default
    
    @Published var videos: [Video]
    @Published var period: Int {
        didSet {
            userDefaults.savePeriod(period)
        }
    }
    
    @Published var isCalculating: Bool = false
    @Published var isGrabbing: Bool = false
    
    @Published var error: GrabShotError?
    @Published var showAlert = false
    
    @Published var grabCounter: Int
    @Published var showAlertDonate: Bool = false
    @Published var showRequestReview: Bool = false
    
    @Published var sortOrder: [KeyPathComparator<Video>] = [keyPathComparator]
    
    static let keyPathComparator = KeyPathComparator<Video>(\.title, order: SortOrder.forward)
    
    private var store = Set<AnyCancellable>()
    private var backgroundGlobalQueue = DispatchQueue.global(qos: .background)
    
    init() {
        videos = []
        period = userDefaults.period
        grabCounter = userDefaults.grabCount
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
        DispatchQueue.main.async {
            self.grabCounter += count
        }
    }
    
    func syncGrabCounter(_ counter: Int) {
        userDefaults.saveGrabCount(counter)
        grabCounter = userDefaults.grabCount
    }
    
    private func bindGrabCounter() {
        $grabCounter
            .receive(on: backgroundGlobalQueue)
            .sink { [weak self] counter in
                let grabCounter = Counter()
                if grabCounter.triggerGrab(for: .donate, counter: counter) {
                    sleep(Counter.triggerSleepSeconds)
                    DispatchQueue.main.async {
                        self?.showAlertDonate = true
                    }
                }
                
                if grabCounter.triggerGrab(for: .review, counter: counter) {
                    sleep(Counter.triggerSleepSeconds)
                    DispatchQueue.main.async {
                        self?.showRequestReview = true
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

extension VideoStore {
    
    var sortedVideos: [Video] {
        return self.videos
            .sorted(using: sortOrder)
    }
}
