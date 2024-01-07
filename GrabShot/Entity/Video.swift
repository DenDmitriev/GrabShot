//
//  Video.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI
import Combine
import MetadataVideoFFmpeg

class Video: Identifiable, ObservableObject {
    var id: UUID
    
    /// Название видео файла
    var title: String
    
    /// Ссылка расположение видео на диске
    var url: URL
    
    /// Название для захваченных кадров
    var grabName: String
    
    /// Размер видео в пикселях
    var size: CGSize?
    
    /// Пропорции изображения
    var aspectRatio: Double?
    
    /// Обложка для видео
    @Published var coverURL: URL?
    
    /// Изображения захваченные из видео
    @Published var images = [URL]()
    
    @ObservedObject var progress: Progress
    
    /// Выбранный диапазон
    @Published var rangeTimecode: ClosedRange<Duration>?
    
    /// Последний выбранный диапазон
    @Published var lastRangeTimecode: ClosedRange<Duration>?
    
    /// Полный диапазон
    @Published var timelineRange: ClosedRange<Duration>
    
    /// Текущий тип диапазона
    @Published var range: RangeType = .full
    
    /// Папка для экспорта
    @Published var exportDirectory: URL?
//    @Published var inQueue: Bool = true
    @Published var metadata: MetadataVideo?
    
    /// Длительность видео
    @Published var duration: TimeInterval
    
    /// Кадров в секунду
    @Published var frameRate: Double
    
    /// Триггер обновления
    @Published var didUpdatedProgress: Bool = false
    
    /// Цвета полученные из видео
    @Published var grabColors: [Color] = []
    
    /// Цвета полученные из видео для таймлайна
    @Published var timelineColors: [Color] = []
    
    /// Переключатель для обозначения участия видео в процессах
    @Published var isEnable: Bool = true {
        didSet {
            didUpdatedProgress.toggle()
        }
    }
    
    /// Ссылка расположение кеша для видео на диске
    var cacheUrl: URL? = nil
    
    var cancellable = Set<AnyCancellable>()
    private weak var videoStore: VideoStore?
    
    init(url: URL, store: VideoStore?) {
        self.id = UUID()
        self.url = url
        self.videoStore = store
        self.title = url.deletingPathExtension().lastPathComponent
        self.grabName = title
        self.duration = 0.0
        self.frameRate = 1
        self.progress = .init(total: .zero)
        self.timelineRange = .init(uncheckedBounds: (lower: .zero, upper: .seconds(1)))
        
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
            timeInterval = rangeTimecode?.timeInterval ?? .zero
        }
        
        let shots = Int(timeInterval.rounded(.down)) / period
        
        if progress.total != shots + 1 {
            progress.current = .zero // чтоб не было конфилкта в прогрессе обнуляем прогресс
            progress.total = shots + 1 // добавляем нулевой шот
        }
        
        didUpdatedProgress.toggle()
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.grabColors.removeAll()
            self.progress.current = .zero
        }
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
    
    /// Получить цвета видео
    /// Прогресс от 0...1
    func fetchTimelineColors(with period: Int = 5, progress: @escaping ((Double, Duration) -> Void)) async throws {
        guard let cacheUrl else { throw VideoServiceError.createCacheVideoFailure }
        // Создаю таймкоды для извлечения по ним цветов
        var timecodes = Array(stride(from: 0.0, through: duration, by: Double(period)))
            .map({ double -> Duration in .seconds(double) })
        // Добавляю финальный таймкод для замыкания всего видео если его нет
        if timecodes.last != .seconds(duration) {
            timecodes.append(.seconds(duration))
        }
        let colorMood = ColorMood()
        let colorCount = 5 // считаем что 5 цветов достаточно для отображения характера
        lastRangeTimecode = .init(uncheckedBounds: (lower: .seconds(.zero), upper: .seconds(.zero)))
        
        for (index, timecode) in timecodes.enumerated() {
            let cgImage = try VideoService.image(video: cacheUrl, by: timecode)
            var colors = try await ColorsExtractorService.extract(
                from: cgImage,
                method: colorMood.method,
                count: colorCount,
                formula: colorMood.formula,
                flags: colorMood.flags
            ).map({ Color(cgColor: $0) })
            
            // Добавляем недостающие цвета в виде черного
            while colors.count < colorCount {
                colors.append(.black)
            }
            
            // Для синхронного отображения видео и таймлайна нужно убрать излишние цвета в последней итерации
            // чтобы остальные цвета до этого остались на месте
            if index == timecodes.count - 1, index > 1 {
                while colors.count > Int((timecode - timecodes[index - 1]).seconds) {
                    colors.removeLast()
                }
            }
            
            timelineColors.append(contentsOf: colors)
            
            if let lastRangeTimecode {
                self.lastRangeTimecode = .init(uncheckedBounds: (lower: lastRangeTimecode.lowerBound, upper: timecode))
            }
            
            let progressValue = Double(index + 1) / Double(timecodes.count)
            
            progress(progressValue, timecode)
        }
    }
    
    // MARK: - Private methods
    /// Получение длительности видео
    /// Задаются значения таймкодов начала и конца захвата
    /// Подписка на обновления области захвата изображений
    private func bindToDuration() {
        $duration
            .receive(on: RunLoop.main)
            .sink { [weak self] duration in
                if duration != .zero {
                    self?.updateShotsForGrab()
                }
                self?.timelineRange = .init(uncheckedBounds: (lower: .seconds(.zero), upper: .seconds(duration)))
                self?.rangeTimecode = .init(uncheckedBounds: (lower: .seconds(.zero), upper: .seconds(duration)))
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
    
    // Подписка на изменения таймкода начала и конца захвата
    private func bindToTimecodes() {
        $rangeTimecode
            .receive(on: RunLoop.main)
            .sink { [weak self] range in
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
//        let imageUrl = Bundle.main.url(forResource: "Placeholder", withExtension: "jpg")!
//        video.images = [imageUrl]
        video.duration = 5
        video.grabColors = [
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
