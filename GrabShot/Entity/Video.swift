//
//  Video.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI
import Combine

class Video: Identifiable, Equatable, Hashable {
    var id: Int
    var title: String
    var url: URL
    var colors: [Color]?
    
    @ObservedObject var session = Session.shared
    
    @ObservedObject var progress: Progress
    
    @ObservedObject var fromTimecode: Timecode = .init(timeInterval: .zero)
    @ObservedObject var toTimecode: Timecode = .init(timeInterval: .zero)
    @Published var range: RangeType = .full
    
    @Published var exportDirectory: URL?
    @Published var isEnable: Bool = true {
        didSet {
            didUpdatedProgress.toggle()
        }
    }
    @Published var inQueue: Bool = true
    @Published var duration: TimeInterval
    @Published var didUpdatedProgress: Bool = false
    
    private var store = Set<AnyCancellable>()
    
    init(url: URL) {
        self.id = Session.shared.videos.count
        self.url = url
        self.title = url.deletingPathExtension().lastPathComponent
        self.duration = 0.0
        self.progress = .init(total: .zero)
        bindToDuration()
        bindToPeriod()
    }
    
    enum Value {
        case duration, shots, all
    }
    
    func updateShots(for period: Int? = nil, by range: RangeType? = nil) {
        let period = period ?? Session.shared.period
        
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
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
    
    func bindToPeriod() {
        session.$period
            .sink { [weak self] period in
                self?.updateShots()
            }
            .store(in: &store)
    }
    
    func bindToRange() {
        $range
            .sink { [weak self] range in
                self?.updateShots(by: range)
            }
            .store(in: &store)
    }
    
    func bindToTimecodes() {
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
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.url == rhs.url
    }
}
