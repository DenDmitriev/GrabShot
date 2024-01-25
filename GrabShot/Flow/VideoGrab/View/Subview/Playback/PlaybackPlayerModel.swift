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
    @Published var isMatchFrameProgress: Bool = false
    @Binding var playhead: Duration
    @Published var playbackStatus: PlaybackStatus = .unknown
    @Published var statusPlayer: AVPlayer.Status = .unknown
    @Published var statusVideo: AVPlayerItem.Status = .unknown
    @Published var statusTimeControl: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate
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
        addPlayerStatusObserver(for: player)
        if let itemStatusObserver = buildPlayerItemStatusObserver(for: player) {
            playerObservers.insert(itemStatusObserver)
        }
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
    
    /// Наблюдатель статуса видео файла в плеере
    private func buildPlayerItemStatusObserver(for player: AVPlayer?) -> NSKeyValueObservation? {
        return player?.currentItem?.observe(\.status, options: .new) { [weak self] item, status in
            DispatchQueue.main.async {
                self?.statusVideo = item.status
            }
        }
    }
    
    /// Наблюдатель над ответственным за контролем  изменением текущего времени
    private func addPlayerStatusObserver(for player: AVPlayer?) {
        if let observer = player?.observe(\.status, changeHandler: { player, status in
            DispatchQueue.main.async {
                self.statusPlayer = player.status
            }
        }) {
            playerObservers.insert(observer)
        }
    }
    
    private func reloadPlayer(url: URL?) {
        guard let url else { return }
        removeObservers()
        updateStatusPlayback(status: .loading)
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
                    self?.updateStatusPlayback(status: .caching)
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
                self.statusTimeControl = player.timeControlStatus
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
    func matchFrame(time: CMTime, video: Video) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return }
        let url = video.cacheUrl ?? video.url
        let seconds: Duration = .seconds(time.seconds)
        let timecodeFormated = seconds.formatted(.timecode(frameRate: video.frameRate, separator: "."))
        let name = video.grabName + "." + timecodeFormated
        let imageInCacheURL = cachesDirectory.appendingPathComponent(name)
        Task {
            progressMatchFrame(is: true)
            let result = await AVVideoService.image(video: url, by: time)
            switch result {
            case .success(let cgImage):
                try FileService.writeImage(cgImage: cgImage, to: imageInCacheURL, format: .jpeg) { imageURL in
                    addImage(by: imageURL, to: video)
                }
            case .failure(let failureAV):
                // Пробуем второй вариант получения скриншота
                let resultFFmpeg = try await matchFrameByFFmpeg(time: time, video: video)
                switch resultFFmpeg {
                case .success(let imageURL):
                    addImage(by: imageURL, to: video)
                case .failure(let failureFFmpeg):
                    presentErrors([failureAV, failureFFmpeg])
                }
            }
            progressMatchFrame(is: false)
        }
    }
    
    /// Match frame снимок кадра и отправка в ImageStore
    /// Используя FFmpeg
    func matchFrameByFFmpeg(time: CMTime, video: Video) async throws -> Result<URL, Error> {
        let quality = UserDefaultsService.default.quality
        let result = try await FFmpegVideoService.grab(in: video, to: .cache, timecode: .seconds(time.seconds), quality: quality)
        return result
    }
    
    private func addImage(by url: URL, to video: Video) {
        DispatchQueue.main.async {
            video.images.append(url)
            self.coordinator?.imageStore.insertImages([url])
        }
    }
    
    private func updateStatusPlayback(status: PlaybackStatus) {
        DispatchQueue.main.async {
            self.playbackStatus = status
        }
    }
    
    /// Кеширование видео файла
    private func cache(video: Video, completion: @escaping ((URL?) -> Void)) {
        progress(is: true)
        DispatchQueue.global(qos: .userInitiated).async {
            FFmpegVideoService.cache(for: video) { [weak self] result in
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
    
    private func progressMatchFrame(is progress: Bool) {
        DispatchQueue.main.async {
            self.isMatchFrameProgress = progress
        }
    }
    
    private func presentError(_ error: Error) {
        DispatchQueue.main.async {
            let error = error as NSError
            self.error = .map(errorDescription: error.localizedDescription, failureReason: error.localizedFailureReason)
            self.hasError = true
            self.coordinator?.presentAlert(error: GrabError.map(errorDescription: error.localizedDescription, failureReason: error.localizedFailureReason))
        }
    }
    
    private func presentErrors(_ errors: [Error]) {
        var errorDescription: String = ""
        var failureReason: String = ""
        
        for (index, error) in errors.enumerated() {
            let error = error as NSError
            if index != .zero {
                errorDescription.append(contentsOf: "\n")
                failureReason.append(contentsOf: "\n")
            }
            errorDescription += error.localizedDescription
            failureReason += error.localizedFailureReason ?? ""
        }
        DispatchQueue.main.async {
            self.error = .map(errorDescription: errorDescription, failureReason: failureReason)
            self.hasError = true
            self.coordinator?.presentAlert(error: GrabError.map(errorDescription: errorDescription, failureReason: failureReason))
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
