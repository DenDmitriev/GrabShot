//
//  LinkGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.01.2024.
//

import SwiftUI
import Cocoa
import WebKit

struct YouTubeView: NSViewRepresentable {
    var url: URL?
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        guard let url else { return }
        let request = URLRequest(url: url)
        nsView.load(request)
    }
}

struct LinkGrabView: View {
    @State var url: URL? = URL(string: "https://youtu.be/dQw4w9WgXcQ")
    
    var body: some View {
        VStack {
            Text("Demo")
                .font(.title)
            
            YouTubeView(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    guard let url else { return }
                    Task {
                        try await YoutubeParser.h264videosWithYoutubeURL(youtubeURL: url, completion: { dict, error in
                            print(dict)
                            print(error)
                        })
                    }
                }
        }
    }
}

#Preview {
    LinkGrabView()
        .frame(width: 600, height: 400)
}
