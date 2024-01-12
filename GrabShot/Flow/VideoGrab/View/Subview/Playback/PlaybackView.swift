//
//  VideoPlayerView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 25.12.2023.
//

import SwiftUI
import AVKit

struct PlaybackView: View {
    @StateObject var viewModel: PlaybackViewModel
    @ObservedObject var video: Video
    @State var isPlaying: Bool = false
    @State var isControl: Bool = true
    @Binding var playhead: Duration
    @State var isProgress: Bool = false
    @State var showError: Bool = false
    
    init(video: Video, playhead: Binding<Duration>) {
        self.video = video
        self._playhead = playhead
        self._viewModel = StateObject(wrappedValue: PlaybackViewModel())
    }
    
    var body: some View {
        VideoPlayer(player: viewModel.player)
            .overlay {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    ProgressView()
                }
                .hidden(!isProgress)
            }
            .onChange(of: video) { newVideo in
                buildPlayback(video: newVideo)
            }
            .onChange(of: playhead) { newPlayhead in
                if isControl {
                    if viewModel.player?.timeControlStatus == .playing {
                        viewModel.player?.pause()
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
                buildPlayer(video: video)
                
                // Если видео не поддерживается, то создаем его в кеше через FFmpeg
                let observer = createVideoStatusObserver(for: viewModel.player, video: video)
                viewModel.addObserver(observer: observer)
            }
            .onDisappear {
                //remove observers
                viewModel.removeObserver(for: viewModel.player)
            }
            .frame(minHeight: AppGrid.pt256)
    }
    
    private func buildPlayback(video: Video) {
        // Remove previous playback
        // Remove observers
        viewModel.removeObserver(for: viewModel.player)
        
        // Create playback for new video
        buildPlayer(video: video)
        
        // Если видео не поддерживается, то создаем его в кеше через FFmpeg
        let observer = createVideoStatusObserver(for: viewModel.player, video: video)
        viewModel.addObserver(observer: observer)
    }
    
    private func addTimeObserver(for player: AVPlayer?, every interval: Double) {
        viewModel.timeObserver = viewModel.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: interval, preferredTimescale: 600), queue: nil, using: { cmTime in
            withAnimation(.linear(duration: interval)) {
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
    
    private func createVideoStatusObserver(for player: AVPlayer?, video: Video) -> NSKeyValueObservation? {
        return player?.currentItem?.observe(\.status, options: .new ,changeHandler: { item, status in
            switch item.status {
            case .failed:
                viewModel.cache(video: video) { url in
                    if let url {
                        DispatchQueue.main.async {
                            buildPlayer(video: video)
                        }
                    }
                }
            default:
                return
            }
        })
    }
    
    private func buildPlayer(video: Video) {
        viewModel.player = AVPlayer(url: video.url)
        let intervalObserver = 1 / video.frameRate
        addTimeObserver(for: viewModel.player, every: intervalObserver)
        let statusObserver = createPlayerStatusObserver(for: viewModel.player)
        viewModel.addObserver(observer: statusObserver)
    }
    
    private func toTimePlayer(seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        viewModel.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

#Preview {
    let video: Video = .placeholder
    
    return PlaybackView(video: video, playhead: .constant(.zero))
}
