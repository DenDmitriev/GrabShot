//
//  PlaybackToolbar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.01.2024.
//

import SwiftUI
import AVKit

struct PlaybackToolbar: View {
    @ObservedObject var video: Video
    @Binding var player: AVPlayer?
    @Binding var isPlaying: Bool
    @StateObject var viewModel: PlaybackPlayerModel
    
    var body: some View {
        HStack {
            // Additional buttons
            
            Spacer()
            
            // Playback control buttons
            Button {
                guard let toTime = stepByFrame(player: player, to: .backward) else { return }
                player?.seek(to: toTime, toleranceBefore: .zero, toleranceAfter: .zero)
            } label: {
                Image(systemName: "backward.frame.fill")
            }
            .help(String(localized: "Go to previous frame", comment: "Help"))
            
            Button {
                isPlaying ? player?.pause() : player?.play()
            } label: {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            }
            .help(isPlaying 
                  ? String(localized: "Pause", comment: "Help")
                  : String(localized: "Play", comment: "Help"))
            
            Button {
                guard let toTime = stepByFrame(player: player, to: .forward) else { return }
                player?.seek(to: toTime, toleranceBefore: .zero, toleranceAfter: .zero)
            } label: {
                Image(systemName: "forward.frame.fill")
            }
            .help(String(localized: "Go to next frame", comment: "Help"))
            
            Spacer()
            
            // Additional buttons
            
            Button {
                matchFrame(player: player, video: video)
            } label: {
                Image("GrabShotInvert")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .help(String(localized: "Match Frame", comment: "Help"))
        }
        .buttonStyle(.icon)
        .padding(AppGrid.pt8)
        .frame(maxWidth: .infinity)
    }
    
    private func matchFrame(player: AVPlayer?, video: Video) {
        guard let time = player?.currentItem?.currentTime() else { return }
        viewModel.matchFrame(time: time, video: video)
    }
    
    private func stepByFrame(player: AVPlayer?, to direction: Direction) -> CMTime? {
        guard let time = player?.currentItem?.currentTime() else { return nil }
        
        let timescale = time.timescale <= 1 ? Int32(video.frameRate) : time.timescale
        
        let onFrameTime = CMTime(seconds: 1 / video.frameRate, preferredTimescale: timescale)
        
        switch direction {
        case .forward:
            return CMTimeAdd(time, onFrameTime)
        case .backward:
            return CMTimeSubtract(time, onFrameTime)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @ObservedObject var video: Video = .placeholder
        @State var player: AVPlayer? = .init(url: Video.placeholder.url)
        @State var isPlaying: Bool = false
        @State var frameRate: Double = 24
        @StateObject var viewModel: PlaybackPlayerModel = PlaybackPlayerModel(playhead: .constant(.zero))
        
        var body: some View {
            PlaybackToolbar(video: video, player: $player, isPlaying: $isPlaying, viewModel: viewModel)
        }
    }
    return PreviewWrapper()
        .padding()
}

extension PlaybackToolbar {
    enum Direction {
        case forward, backward
    }
}
