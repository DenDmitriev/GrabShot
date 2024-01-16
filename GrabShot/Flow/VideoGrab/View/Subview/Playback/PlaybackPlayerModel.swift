//
//  PlaybackPlayerModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 12.01.2024.
//

import SwiftUI
import AVKit

class PlaybackPlayerModel: ObservableObject {
    @Published var urlPlayer: URL?
    @Published var isProgress: Bool = false
    @Binding var playhead: Duration
    @Published var status: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
    @Published var volume: Float = .zero
    @Published var isMuted: Bool = false
    weak var coordinator: GrabCoordinator?
    var hasError: Bool = false
    var error: PlaybackError?
    
    private var playerObservers = Set<NSKeyValueObservation>()
    
    init(playhead: Binding<Duration>) {
        self._playhead = playhead
    }
    
    /// Создание наблюдателей для работы плеера
    func createObservers(for player: AVPlayer?, video: Video) {
        if let itemStatusObserver = buildPlayerItemStatusObserver(for: player, video: video) {
            playerObservers.insert(itemStatusObserver)
        }
        addPlayerTimeControlStatusObserver(for: player)
        addPlayerVolumeObserver(for: player)
        addPlayerVolumeMutedObserver(for: player)
    }
    
    /// Отключение наблюдателей
    func removeObservers() {
        playerObservers.forEach({ $0.invalidate() })
    }
    
    /// Наблюдатель за перемещение текущего времени в плеере
    /// Частот вызова - каждый кадр
    func addTimeObserver(for player: AVPlayer?, frameRate: Double) {
        let timescale = Int32(frameRate.rounded(.up))
        let intervalForUpdate = 1 / frameRate
        
        let interval = CMTime(seconds: intervalForUpdate, preferredTimescale: timescale)
        player?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { [weak self] cmTime in
            withAnimation(.linear(duration: interval.seconds)) { [weak self] in
//                print("observer update to", cmTime.value, "/", cmTime.timescale)
                self?.playhead = cmTime.duration(frameRate: frameRate)
            }
        })
    }
    
    private func reloadPlayer(url: URL?) {
        guard let url else { return }
        removeObservers()
        DispatchQueue.main.async {
            self.urlPlayer = url
        }
    }
    
    /// Наблюдатель статуса видео файла в плеере
    /// Если файл не поддерживается, то пробуем загрузить кеш или закешировать в поддерживаемом формате
    private func buildPlayerItemStatusObserver(for player: AVPlayer?, video: Video) -> NSKeyValueObservation? {
        return player?.currentItem?.observe(\.status, options: .new) { [weak self] item, status in
            switch item.status {
            case .failed:
                if let url = video.cacheUrl {
                    self?.reloadPlayer(url: url)
                } else {
                    self?.cache(video: video) { url in
                        self?.reloadPlayer(url: url)
                    }
                }
            default: return
            }
        }
    }
    
    /// Наблюдатель над ответственным за контролем  изменением текущего времени
    func addPlayerTimeControlStatusObserver(for player: AVPlayer?) {
        if let observer = player?.observe(\.timeControlStatus, changeHandler: { player, status in
            DispatchQueue.main.async {
                self.status = player.timeControlStatus
            }
        }) {
            playerObservers.insert(observer)
        }
    }
    
    /// Наблюдатель над ответственным за контролем  отключением звука
    func addPlayerVolumeMutedObserver(for player: AVPlayer?) {
        if let observer = player?.observe(\.isMuted, changeHandler: { player, isMuted in
            DispatchQueue.main.async {
                self.isMuted = player.isMuted
            }
        }) {
            playerObservers.insert(observer)
        }
    }
    
    /// Наблюдатель над ответственным за контролем  изменением звука
    func addPlayerVolumeObserver(for player: AVPlayer?) {
        if let observer = player?.observe(\.volume, changeHandler: { player, volume in
            DispatchQueue.main.async {
                self.volume = player.volume
            }
        }) {
            playerObservers.insert(observer)
        }
    }
    
    /// Match frame снимок кадра и отправка в ImageStore
    /// Только для поддерживаемого плейбеком материала, так как не имеет смысла если не видна плейбека
    func matchFrame(time: CMTime, video: Video) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return }
        let url = video.cacheUrl ?? video.url
        let seconds: Duration = .seconds(time.seconds)
        let timecodeFormated = seconds.formatted(.timecode(frameRate: video.frameRate, separator: "."))
        let name = video.grabName + "." + timecodeFormated
        let imageInCacheURL = cachesDirectory.appendingPathComponent(name)
        Task {
            do {
                let cgImage = try await VideoService.image(video: url, by: time)
                try FileService.writeImage(cgImage: cgImage, to: imageInCacheURL, format: .jpeg) { imageURL in
                    DispatchQueue.main.async {
                        video.images.append(imageURL)
                        self.coordinator?.imageStore.insertImages([imageURL])
                    }
                }
            } catch {
                let error = error as NSError
                self.error = .map(errorDescription: error.localizedDescription, failureReason: error.localizedFailureReason)
            }
        }
    }
    
    /// Кеширование видео файла
    private func cache(video: Video, completion: @escaping ((URL?) -> Void)) {
        progress(is: true)
        DispatchQueue.global(qos: .userInitiated).async {
            VideoService.cache(for: video) { [weak self] result in
                self?.progress(is: false)
                switch result {
                case .success(let success):
                    video.cacheUrl = success
                    completion(success)
                case .failure(let failure):
                    if let error = failure as? LocalizedError {
                        self?.presentError(error)
                        completion(nil)
                    }
                }
            }
        }
    }
    
    private func progress(is progress: Bool) {
        DispatchQueue.main.async {
            self.isProgress = progress
        }
    }
    
    private func presentError(_ error: LocalizedError) {
        DispatchQueue.main.async {
            let error = error as NSError
            self.error = .map(errorDescription: error.localizedDescription, failureReason: error.localizedFailureReason)
            self.hasError = true
        }
    }
}

extension PlaybackPlayerModel {
    static func build(playhead: Binding<Duration>, coordinator: GrabCoordinator? = nil) -> PlaybackPlayerModel {
        let viewModel = PlaybackPlayerModel(playhead: playhead)
        
        viewModel.coordinator = coordinator
        
        return viewModel
    }
}
