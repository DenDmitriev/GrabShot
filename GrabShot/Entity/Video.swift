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
    @Published var isEnable: Bool = true
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
        bind()
    }
    
    enum Value {
        case duration, shots, all
    }
    
    func updateShots(for period: Int? = nil) {
        let period = period ?? Session.shared.period
        let shots = Int(duration.rounded(.down)) / period
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
    
    private func bind() {
        $duration
            .receive(on: RunLoop.main)
            .sink { [weak self] duration in
                if duration != .zero {
                    self?.updateShots()
                }
                self?.fromTimecode = Timecode(timeInterval: .zero, maxTimeInterval: duration)
                self?.toTimecode = Timecode(timeInterval: duration, maxTimeInterval: duration)
            }
            .store(in: &store)
        
        session.$period
            .sink { [weak self] period in
                self?.updateShots()
            }
            .store(in: &store)
    }
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.url == rhs.url
    }
}
