//
//  Video.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI
import Combine

class Video: Identifiable {
    var id: UUID
    var title: String
    var url: URL
    
    @Published var coverURL: URL?
    
    @Published var images = [URL]()
    
    @ObservedObject var progress: Progress
    @ObservedObject var fromTimecode: Timecode = .init(timeInterval: .zero)
    @ObservedObject var toTimecode: Timecode = .init(timeInterval: .zero)
    
    @Published var range: RangeType = .full
    @Published var exportDirectory: URL?
    @Published var inQueue: Bool = true
    @Published var duration: TimeInterval
    @Published var didUpdatedProgress: Bool = false
    @Published var colors: [Color]?
    @Published var isEnable: Bool = true {
        didSet {
            didUpdatedProgress.toggle()
        }
    }
    
    @ObservedObject private var videoStore: VideoStore
    
    private var store = Set<AnyCancellable>()
    
    init(url: URL, store: VideoStore) {
        self.id = UUID()
        self.url = url
        self.videoStore = store
        self.title = url.deletingPathExtension().lastPathComponent
        self.duration = 0.0
        self.progress = .init(total: .zero)
        
        bindToDuration()
        bindToPeriod()
        bindToImages()
        bindIsEnable()
        bindExportDirectory()
    }
    
    enum Value {
        case duration, shots, all
    }
    
    func updateShots(for period: Int? = nil, by range: RangeType? = nil) {
        let period = period ?? videoStore.period
        guard period != 0 else { return }
        
        let timeInterval: TimeInterval
        switch range ?? self.range {
        case .full:
            timeInterval = self.duration
        case .excerpt:
            timeInterval = toTimecode.timeInterval - fromTimecode.timeInterval
        }
        
        let shots = Int(timeInterval.rounded(.down)) / period
        
        if progress.total != shots {
            progress.total = shots
        }
        
        didUpdatedProgress.toggle()
    }
    
    func clear() {
        colors?.removeAll()
        progress.current = .zero
    }
    
    func updateCover() {
        guard
            !images.isEmpty,
            let imageURLRandom = images.randomElement()
        else { return }
        let imageURL = imageURLRandom
        DispatchQueue.main.async {
            self.coverURL = imageURL
        }
    }
    
    // MARK: - Private methods
    
    private func bindToDuration() {
        $duration
            .receive(on: RunLoop.main)
            .sink { [weak self] duration in
                if duration != .zero {
                    self?.updateShots()
                }
                self?.fromTimecode = Timecode(timeInterval: .zero, maxTimeInterval: duration)
                self?.toTimecode = Timecode(timeInterval: duration, maxTimeInterval: duration)
                self?.bindToTimecodes()
                self?.bindToRange()
            }
            .store(in: &store)
    }
    
    private func bindToPeriod() {
        videoStore.$period
            .sink { [weak self] period in
                self?.updateShots(for: period)
            }
            .store(in: &store)
    }
    
    private func bindToRange() {
        $range
            .sink { [weak self] range in
                self?.updateShots(by: range)
            }
            .store(in: &store)
    }
    
    private func bindToTimecodes() {
        fromTimecode.$timeInterval
            .receive(on: RunLoop.main)
            .sink { [weak self] timeInterval in
                if self?.range == .excerpt {
                    self?.updateShots()
                }
            }
            .store(in: &store)
        
        toTimecode.$timeInterval
            .receive(on: RunLoop.main)
            .sink { [weak self] timeInterval in
                if self?.range == .excerpt {
                    self?.updateShots()
                }
            }
            .store(in: &store)
    }
    
    private func bindToImages() {
        $images.sink { [weak self] imageURLs in
            guard let self else { return }
            let imageURL: URL
            if imageURLs.count == progress.total {
                guard let imageURLRandom = imageURLs.randomElement() else { return }
                imageURL = imageURLRandom
            } else {
                guard let imageURLLast = imageURLs.last else { return }
                imageURL = imageURLLast
            }
            DispatchQueue.main.async {
                self.coverURL = imageURL
            }
        }
        .store(in: &store)
    }
    
    private func bindIsEnable() {
        $isEnable
            .receive(on: RunLoop.main)
            .sink { [weak self] isEnable in
                self?.videoStore.updateIsGrabEnable()
            }
            .store(in: &store)
    }
    
    private func bindExportDirectory() {
        $exportDirectory
            .receive(on: RunLoop.main)
            .sink { [weak self] exportDirectory in
                self?.videoStore.updateIsGrabEnable()
            }
            .store(in: &store)
    }
}

extension Video: Equatable {
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Video: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Video {
    static var placeholder: Video {
        let url = Bundle.main.url(forResource: "Placeholder", withExtension: "mov")!
        let video = Video(url: url, store: VideoStore())
        video.colors = [
            Color.black,
            Color.gray,
            Color.white,
            Color.red,
            Color.orange,
            Color.yellow,
            Color.green,
            Color.cyan,
            Color.blue,
            Color.purple
        ]
        
        return video
    }
}
