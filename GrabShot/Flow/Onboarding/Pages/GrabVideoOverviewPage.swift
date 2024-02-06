//
//  GrabOverviewPage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct GrabVideoOverviewPage: View, OnboardingAnimatable {
    @State private var imageSize: CGSize = .zero
    
    // Selections
    private let magnificationShape: some Shape = RoundedRectangle(cornerRadius: AppGrid.pt8)
    @State private var magnificationSize: CGSize = .zero
    @State private var positionImportedVideos: CGSize = CGSize(width: 0.128, height: 0.512)
    @State private var positionPlayback: CGSize = CGSize(width: 0.471, height: 0.389)
    @State private var positionGrabPanel: CGSize = CGSize(width: 0.843, height: 0.389)
    @State private var positionTimeline: CGSize = CGSize(width: 0.586, height: 0.77)
    
    // Animation
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var showers: [Binding<Bool>] = []
    @State private var isShowImportedVideos: Bool = false
    @State private var isShowPlayback: Bool = false
    @State private var isShowGrabPanel: Bool = false
    @State private var isShowTimeline: Bool = false
    
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: String(localized: "Video grabbing"), caption: String(localized: "After importing the video, you will be taken to the video grab tab."))
            
            VStack {
                Text("The window consists of a pool of imported videos and a functional part. Click on the video and you will see the playback, settings and timeline panels in the functional part.")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Image("GrabQueueOverview")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .readSize(onChange: { size in
                        imageSize = size
                    })
                    .cornerRadius(AppGrid.pt16)
                    .magnification(title: "Video pool", scale: .zero, size: CGSize(width: imageSize.width * 0.172, height: imageSize.height * 0.76), shape: magnificationShape, position: positionImportedVideos, isShow: $isShowImportedVideos)
                    .magnification(title: "Grab Panel", scale: .zero, size: CGSize(width: imageSize.width * 0.228, height: imageSize.height * 0.516), shape: magnificationShape, position: positionGrabPanel, isShow: $isShowGrabPanel)
                    .magnification(title: "Playback", scale: .zero, size: CGSize(width: imageSize.width * 0.514, height: imageSize.height * 0.516), shape: magnificationShape, position: positionPlayback, isShow: $isShowPlayback)
                    .magnification(title: "Timeline", scale: .zero, size: CGSize(width: imageSize.width * 0.743, height: imageSize.height * 0.244), shape: magnificationShape, position: positionTimeline, alignment: .bottom, isShow: $isShowTimeline)
                    .onAppear {
                        showers = [$isShowImportedVideos,
                                   $isShowGrabPanel,
                                   $isShowPlayback,
                                   $isShowTimeline]
                    }
                    .onReceive(timer) { _ in
                        timerAnimationReceiver(showers: showers, timer: timer)
                    }
            }
            .padding()
        }
    }
}

#Preview {
    GrabVideoOverviewPage()
        .frame(width: AppGrid.minWidthOverview, height: AppGrid.minHeightOverview)
}
