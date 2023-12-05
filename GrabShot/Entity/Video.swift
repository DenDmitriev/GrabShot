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
    
    var cancellable = Set<AnyCancellable>()
    private weak var videoStore: VideoStore?
    
    init(url: URL, store: VideoStore?) {
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
    
    deinit {
        if self.title != "Placeholder" {
            print(#function, self.title)
        }
    }
    
    enum Value {
        case duration, shots, all
    }
    
    func updateShotsForGrab(for period: Int? = nil, by range: RangeType? = nil) {
        guard let period = period ?? videoStore?.period else { return }
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
    
    func reset() {
        colors?.removeAll()
        progress.current = .zero
    }
    
    func updateCover() {
        guard !images.isEmpty,
              let imageURLRandom = images.randomElement()
        else { return }
        let imageURL = imageURLRandom
        DispatchQueue.main.async {
            self.coverURL = imageURL
        }
    }
    
    func willDelete() {
        cancellable.forEach { cancellable in
            cancellable.cancel()
        }
        cancellable.removeAll()
    }
    
    // MARK: - Private methods
    // Получение длительности видео
    // Задаются значения таймкодов начала и конца захвата
    // Подписка на обновления области захвата изображений
    private func bindToDuration() {
        $duration
            .receive(on: RunLoop.main)
            .sink { [weak self] duration in
                if duration != .zero {
                    self?.updateShotsForGrab()
                }
                self?.fromTimecode = Timecode(timeInterval: .zero, maxTimeInterval: duration)
                self?.toTimecode = Timecode(timeInterval: duration, maxTimeInterval: duration)
                self?.bindToTimecodes()
                self?.bindToRange()
            }
            .store(in: &cancellable)
    }
    
    // Подписка на изменения периода для захвата
    private func bindToPeriod() {
        videoStore?.$period
            .sink { [weak self] period in
                self?.updateShotsForGrab(for: period)
            }
            .store(in: &cancellable)
    }
    
    // Подписка на изменения области захвата изображений
    private func bindToRange() {
        $range
            .sink { [weak self] range in
                self?.updateShotsForGrab(by: range)
            }
            .store(in: &cancellable)
    }
    
    // Подписка на изменения тааймкода начала и конца захвата
    private func bindToTimecodes() {
        fromTimecode.$timeInterval
            .receive(on: RunLoop.main)
            .sink { [weak self] timeInterval in
                if self?.range == .excerpt {
                    self?.updateShotsForGrab()
                }
            }
            .store(in: &cancellable)
        
        toTimecode.$timeInterval
            .receive(on: RunLoop.main)
            .sink { [weak self] timeInterval in
                if self?.range == .excerpt {
                    self?.updateShotsForGrab()
                }
            }
            .store(in: &cancellable)
    }
    
    
    // Подписка на обновление массива изображений
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
        .store(in: &cancellable)
    }
    
    // Подписка на изменения статуса видео
    private func bindIsEnable() {
        $isEnable
            .receive(on: RunLoop.main)
            .sink { [weak self] isEnable in
                self?.videoStore?.updateIsGrabEnable()
            }
            .store(in: &cancellable)
    }
    
    // Подписка на выбор папки для экспорта изображений из видео
    private func bindExportDirectory() {
        $exportDirectory
            .receive(on: RunLoop.main)
            .sink { [weak self] exportDirectory in
                self?.videoStore?.updateIsGrabEnable()
            }
            .store(in: &cancellable)
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
        let video = Video(url: url, store: nil)
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
