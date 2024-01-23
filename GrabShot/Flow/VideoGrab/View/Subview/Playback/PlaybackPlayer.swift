//
//  PlaybackPlayer.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 12.01.2024.
//
// https://www.kodeco.com/books/swiftui-cookbook/v1.0/chapters/3-customizing-audio-video-playback-in-swiftui

import SwiftUI
import AVKit

struct PlaybackPlayer: View {
    @ObservedObject var video: Video
    @Binding var playhead: Duration
    @Binding var gesturePlayhead: Duration
    @StateObject var viewModel: PlaybackPlayerModel
    @State private var player: AVPlayer?
    @State private var urlPlayer: URL?
    @State private var isProgress: Bool = false
    @State private var controller: Controller = .timeline
    @State private var isPlaying: Bool = false
    @State private var volume: Float = .zero
    @State private var isMuted: Bool = false
    
    var body: some View {
        VStack {
            VStack(spacing: .zero) {
                if let player {
                    VideoPlayer(player: player)
                        .onChange(of: playhead) { newPlayhead in
                            switch controller {
                            case .timeline:
                                toTimePlayer(seconds: newPlayhead)
                            case .playback:
                                return
                            }
                        }
                        .onChange(of: gesturePlayhead) { newGesturePlayhead in
                            toTimePlayer(seconds: newGesturePlayhead)
                        }
                    
                    PlaybackToolbar(video: video, player: $player, isPlaying: $isPlaying, isMuted: $isMuted, volume: $volume, viewModel: viewModel)
                    
                } else {
                    placeholder
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .overlay {
                if isProgress {
                    ProgressView()
                }
            }
        }
        .onAppear {
            urlPlayer = video.url
        }
        .onDisappear {
            viewModel.removeObservers()
        }
        .onChange(of: video) { newVideo in
            urlPlayer = newVideo.url
        }
        .onChange(of: urlPlayer) { newUrlPlayer in
            if let newUrlPlayer {
                viewModel.removeObservers()
                player = AVPlayer(url: newUrlPlayer)
                viewModel.createObservers(for: player, video: video)
                viewModel.addTimeObserver(for: player, frameRate: video.frameRate)
            }
        }
        .onReceive(viewModel.$status) { status in
            switch status {
            case .paused:
                controller = .timeline
                isPlaying = false
            case .playing:
                controller = .playback
                isPlaying = true
            default:
                controller = .timeline
                isPlaying = false
            }
        }
        .onReceive(viewModel.$volume) { volume in
            self.volume = volume
        }
        .onReceive(viewModel.$isMuted) { isMuted in
            self.isMuted = isMuted
        }
        .onReceive(viewModel.$urlPlayer) { urlPlayer in
            self.urlPlayer = urlPlayer
        }
        .onReceive(viewModel.$isProgress) { isProgress in
            self.isProgress = isProgress
        }
        .frame(minHeight: AppGrid.pt300)
    }
    
    private var placeholder: some View {
        Text("Video is not supported")
            .font(.title2)
            .foregroundColor(.secondary)
    }
    
    private func toTimePlayer(seconds: Duration) {
        let timescale = Int32(video.frameRate.rounded(.up))
        let secondsRounded = seconds.seconds(frameRate: video.frameRate)
        let time = CMTime(seconds: secondsRounded, preferredTimescale: timescale)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var playhead: Duration = .zero
        @State var gesturePlayhead: Duration = .zero
        
        var body: some View {
            PlaybackPlayer(video: .placeholder, playhead: $playhead, gesturePlayhead: $gesturePlayhead, viewModel: PlaybackPlayerModel(playhead: $playhead))
        }
    }
    
    return PreviewWrapper()
}

extension PlaybackPlayer {
    enum Controller {
        case timeline, playback
    }
}
