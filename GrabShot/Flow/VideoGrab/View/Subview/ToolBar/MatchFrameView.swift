//
//  MatchFrameView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.01.2024.
//

import SwiftUI

struct MatchFrameView: View {
    
    @State var video: Video
    @Binding var playhead: Duration
    @EnvironmentObject var imageStore: ImageStore
    
    var body: some View {
        Button {
            if let cacheUrl = video.cacheUrl {
                matchFrame(video: cacheUrl)
            }
        } label: {
            Image("GrabShotInvert")
        }
        .help(String(localized: "Match Frame", comment: "Help"))
        .buttonStyle(.plain)
    }
    
    private func matchFrame(video url: URL) {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return }
        do {
            let cgImage = try VideoService.image(video: url, by: playhead)
            let timecodeFormated = playhead.formatted(.timecode(frameRate: video.frameRate)).replacingOccurrences(of: ":", with: ".")
            let name = video.grabName + "." + timecodeFormated
            let imageInCacheURL = cachesDirectory.appendingPathComponent(name)
            try FileService.writeImage(cgImage: cgImage, to: imageInCacheURL, format: .jpeg) { imageURL in
                video.images.append(imageURL)
                imageStore.insertImages([imageURL])
            }
        } catch {
            // TODO: Create alert
            print(error.localizedDescription)
        }
    }
}

#Preview {
    MatchFrameView(video: .placeholder, playhead: .constant(.seconds(3)))
        .padding()
}
