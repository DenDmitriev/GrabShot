//
//  VideoPlayerView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    
    @Environment(\.dismiss) var dissmis

    @State var enableTimecodeStepper: Bool
    
    @StateObject var viewModel: TimecodePickerModel
    @ObservedObject var video: Video
    @State var player: AVPlayer?
    @State var timeObserver: Any?
    @State var isPlaying: Bool = false
    @State var isControl: Bool = true
    
    @State var currentRange: ClosedRange<Duration>
    @Binding var cursor: Duration
    @State var videoPLayerSize: CGSize = .zero
    @State var isProgress: Bool = false
    @State var showError: Bool = false
    
    init(video: Video, cursor: Binding<Duration>) {
        let enableStepper = video.range == .full ? false : true
        self._enableTimecodeStepper = State(initialValue: enableStepper)
        self._video = ObservedObject(initialValue: video)
        self._cursor = cursor
        if video.range == .full {
            self._currentRange = State(wrappedValue: .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration))))
        } else {
            self._currentRange = State(wrappedValue: video.rangeTimecode ?? .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration))))
        }
        self._viewModel = StateObject(wrappedValue: TimecodePickerModel())
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            VideoPlayer(player: player) {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    ProgressView()
                }
                .hidden(!isProgress)
            }
            .frame(height: videoPLayerSize.height)
            .readSize(onChange: { size in
                let height = size.width / (video.aspectRatio ?? 16/9)
                self.videoPLayerSize = .init(width: size.width, height: height)
            })
            
            
            HStack(spacing: AppGrid.pt10) {
//                Button {
//                    withAnimation {
//                        isPlaying ? player?.pause() : player?.play()
//                        isPlaying.toggle()
//                        isControl = !isPlaying
//                    }
//                } label: {
//                    Image(systemName: isPlaying ? "pause" : "play.fill")
//                        .foregroundColor(.white)
//                        .frame(width: AppGrid.pt48, height: AppGrid.pt48)
//                        .background(content: {
//                            RoundedRectangle(cornerRadius: AppGrid.pt8)
//                                .fill(.separator)
//                                .frame(width: AppGrid.pt48, height: AppGrid.pt48)
//                        })
//                        .font(.title.weight(.bold))
//                }
//                .buttonStyle(.borderless)
                
                RangeSliderView(currentBounds: $currentRange, colorBounds: $video.lastRangeTimecode, cursor: $cursor, colors: $video.colors, bounds: video.timelineRange)
            }
            .padding(AppGrid.pt8)
            .onChange(of: cursor) { newCursor in
                if isControl {
                    if player?.timeControlStatus == .playing {
                        player?.pause()
                        isPlaying = false
                    }
                    toTimePlayer(seconds: newCursor.seconds)
                }
            }
            .onChange(of: currentRange.lowerBound) { newLowerBound in
                let newRange = newLowerBound...currentRange.upperBound
                updateRange(range: newRange)
                video.rangeTimecode = newRange
                toTimePlayer(seconds: newRange.lowerBound.seconds)
            }
            .onChange(of: currentRange.upperBound) { newUpperBound in
                let newRange = currentRange.lowerBound...newUpperBound
                updateRange(range: newRange)
                video.rangeTimecode = newRange
                toTimePlayer(seconds: newRange.upperBound.seconds)
            }
        }
        .onReceive(viewModel.$isProgress) { isProgress in
            self.isProgress = isProgress
        }
        .onReceive(viewModel.$error, perform: { error in
            showError = error != nil
        })
        .alert(isPresented: $showError, error: viewModel.error, actions: {
            Button("OK") { }
        })
        .onAppear {
            buildPlayer(url: video.url)
            
            // Если видео не поддерживается, то создаем его в кеше через FFmpeg
            let observer = createVideoStatusObserver(for: player)
            viewModel.addObserver(observer: observer)
        }
        .onDisappear {
            //remove observers
            if let timeObserver {
                player?.removeTimeObserver(timeObserver)
            }
            // close player
            player = nil
        }
    }
    
    private func addTimeObserver(for player: AVPlayer?) {
        let intervalObserver = 0.1
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: intervalObserver, preferredTimescale: 600), queue: nil, using: { cmTime in
            withAnimation(.linear(duration: intervalObserver)) {
                cursor = .seconds(cmTime.seconds)
            }
        })
    }
    
    private func createPlayerStatusObserver(for player: AVPlayer?) -> NSKeyValueObservation? {
        return player?.observe(\.timeControlStatus, changeHandler: { player, status in
            switch player.timeControlStatus {
            case .paused:
                isControl = true
                isPlaying = false
            case .playing:
                isControl = false
                isPlaying = true
            default:
                isControl = false
                isPlaying = false
            }
            
        })
    }
    
    private func createVideoStatusObserver(for player: AVPlayer?) -> NSKeyValueObservation? {
        return player?.currentItem?.observe(\.status, options: .new ,changeHandler: { item, status in
            switch item.status {
            case .failed:
                viewModel.cache(video: video) { url in
                    if let url {
                        DispatchQueue.main.async {
                            buildPlayer(url: url)
                        }
                    }
                }
            default:
                return
            }
        })
    }
    
    private func buildPlayer(url: URL) {
        player = AVPlayer(url: url)
        addTimeObserver(for: player)
        let statusObserver = createPlayerStatusObserver(for: player)
        viewModel.addObserver(observer: statusObserver)
    }
    
    private func toTimePlayer(seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func updateRange(range: ClosedRange<Duration>) {
        if range.lowerBound == video.timelineRange.lowerBound && range.upperBound == video.timelineRange.upperBound {
            toggleRange(range: .full)
        } else {
            toggleRange(range: .excerpt)
        }
    }
    
    private func toggleRange(range: RangeType) {
        if video.range != range {
            video.range = range
        }
        enableTimecodeStepper = range == .excerpt ? true : false
    }
}

#Preview {
    let video: Video = .placeholder

    return VideoPlayerView(video: video, cursor: .constant(.zero))
}
