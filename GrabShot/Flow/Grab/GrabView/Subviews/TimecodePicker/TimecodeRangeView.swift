//
//  TimecodeRangeView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import SwiftUI
import AVKit

struct TimecodeRangeView: View {
    
    @FocusedBinding(\.showRangePicker) var showRangePicker
    @Environment(\.dismiss) var dissmis

    @State var enableTimecodeStepper: Bool
    
    @StateObject var viewModel: TimecodePickerModel
    @State var video: Video
    @State var player: AVPlayer?
    @State var timeObserver: Any?
    @State var isPlaying: Bool = false
    @State var isControl: Bool = true
    
    @State var currentRange: ClosedRange<Duration>
    @State var cursor: Duration = .zero
    @State var videoPLayerFrame: CGRect = .zero
    @State var isProgress: Bool = false
    @State var showError: Bool = false
    
    init(video: Video) {
        let enableStepper = video.range == .full ? false : true
        self._enableTimecodeStepper = State(initialValue: enableStepper)
        self._video = State(initialValue: video)
        if video.range == .full {
            self._currentRange = State(wrappedValue: .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration))))
        } else {
            self._currentRange = State(wrappedValue: video.rangeTimecode ?? .init(uncheckedBounds: (lower: .zero, upper: .seconds(video.duration))))
        }
        self._viewModel = StateObject(wrappedValue: TimecodePickerModel())
    }
    
    var body: some View {
        VStack {
            VideoPlayer(player: player) {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    ProgressView()
                }
                .hidden(!isProgress)
            }
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear
                        .onAppear {
                            let frame = geometryProxy.frame(in: .local)
                            let height = frame.width / (video.aspectRatio ?? 16/9)
                            self.videoPLayerFrame = .init(x: .zero, y: .zero, width: frame.width, height: height)
                        }
                }
            )
            .frame(height: videoPLayerFrame.height)
            
            HStack(spacing: AppGrid.pt10) {
                Button {
                    withAnimation {
                        isPlaying ? player?.pause() : player?.play()
                        isPlaying.toggle()
                        isControl = !isPlaying
                    }
                } label: {
                    Image(systemName: isPlaying ? "pause" : "play.fill")
                        .foregroundColor(.white)
                        .frame(width: AppGrid.pt48, height: AppGrid.pt48)
                        .background(content: {
                            RoundedRectangle(cornerRadius: AppGrid.pt8)
                                .fill(.white.opacity(0.25))
                                .frame(width: AppGrid.pt48, height: AppGrid.pt48)
                        })
                        .font(.title.weight(.bold))
                }
                .buttonStyle(.borderless)
                
                RangeSliderView(currentBounds: $currentRange, cursor: $cursor, sliderBounds: video.timeline)
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
        .background(.black)
        .overlay(alignment: .topTrailing, content: {
            Button {
                showRangePicker = false
                dissmis()
            } label: {
                Text("Done")
                    .padding(AppGrid.pt6)
                    .background(.yellow)
                    .cornerRadius(AppGrid.pt4)
            }
            .buttonStyle(.borderless)
            .padding()
        })
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
        .frame(minWidth: AppGrid.minWidth - AppGrid.pt32)
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
        if range.lowerBound == video.timeline.lowerBound && range.upperBound == video.timeline.upperBound {
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

struct TimecodeRangeView_Previews: PreviewProvider {
    static let video: Video = .placeholder
    static var previews: some View {
        TimecodeRangeView(video: video)
    }
}
