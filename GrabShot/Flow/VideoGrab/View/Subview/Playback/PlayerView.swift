//
//  PlayerView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.01.2024.
//
// https://www.kodeco.com/books/swiftui-cookbook/v1.0/chapters/3-customizing-audio-video-playback-in-swiftui
// Example

import SwiftUI
import Cocoa
import AVKit
import AVFoundation

struct PlayerView: NSViewRepresentable {
    typealias NSViewType = AVPlayerView
    
    let player: AVPlayer
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .none
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        print(#function)
    }
}

struct PlayerContentView: View {
    let player = AVPlayer(url: Video.placeholder.url)
    
    var body: some View {
        VStack {
            PlayerView(player: player)
            
            HStack(spacing: 20) {
                Button(action: {
                    self.player.volume = max(self.player.volume - 0.1, 0.0)
                }) {
                    Image(systemName: "speaker.fill")
                }
                .buttonStyle(.icon)
                
                
                Button(action: {
                    self.player.volume = min(self.player.volume + 0.1, 1.0)
                }) {
                    Image(systemName: "speaker.wave.3.fill")
                }
                .buttonStyle(.icon)
                
                Button(action: {
                    self.player.play()
                }) {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.icon)
                
                Button(action: {
                    self.player.pause()
                }) {
                    Image(systemName: "pause.fill")
                }
                .buttonStyle(.icon)
                
                Button(action: {
                    self.player.rate += 0.1
                }) {
                    Image(systemName: "slowmo")
                }
                .buttonStyle(.icon)
            }
            .font(.largeTitle)
            .padding()
        }
    }
}

#Preview {
    PlayerContentView()
}
