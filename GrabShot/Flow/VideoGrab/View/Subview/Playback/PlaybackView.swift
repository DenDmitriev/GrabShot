//
//  VideoPlayerView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI
import AVKit

struct PlaybackView: View {
    
    @Environment(\.dismiss) var dissmis
    
    @StateObject var viewModel: VideoPLayerViewModel
    @ObservedObject var video: Video
    @State var player: AVPlayer?
    @State var timeObserver: Any?
    @State var isPlaying: Bool = false
    @State var isControl: Bool = true
    @Binding var playhead: Duration
    @State var isProgress: Bool = false
    @State var showError: Bool = false
    
    init(video: Video, playhead: Binding<Duration>) {
        self._video = ObservedObject(initialValue: video)
        self._playhead = playhead
        self._viewModel = StateObject(wrappedValue: VideoPLayerViewModel())
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .overlay {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    ProgressView()
                }
                .hidden(!isProgress)
            }
            .onChange(of: playhead) { newPlayhead in
                if isControl {
                    if player?.timeControlStatus == .playing {
                        player?.pause()
                        isPlaying = false
                    }
                    toTimePlayer(seconds: newPlayhead.seconds)
                }
            }
            .onReceive(viewModel.$isProgress) { isProgress in
                self.isProgress = isProgress
            }
            .onReceive(viewModel.$error, perform: { error in
                showError = error != nil
            })
            .alert(isPresented: $showError, error: viewModel.error, actions: { _ in
                Button("OK") { }
            }, message: { error in
                if let failureReason = error.failureReason {
                    Text(failureReason)
                }
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
            .frame(minHeight: AppGrid.pt256)
    }
    
    private func addTimeObserver(for player: AVPlayer?) {
        let intervalObserver = 0.1
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: intervalObserver, preferredTimescale: 600), queue: nil, using: { cmTime in
            withAnimation(.linear(duration: intervalObserver)) {
                playhead = .seconds(cmTime.seconds)
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
}

#Preview {
    let video: Video = .placeholder
    
    return PlaybackView(video: video, playhead: .constant(.zero))
}
