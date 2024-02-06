//
//  GrabVideoWorkspaceOverviewPage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.01.2024.
//

import SwiftUI

struct GrabVideoWorkspaceOverviewPage: View, OnboardingAnimatable {
    @State private var imageSize: CGSize = .zero
    
    // Animation
    private let magnificationShape: some Shape = RoundedRectangle(cornerRadius: AppGrid.pt8)
    @State private var magnificationSize: CGSize = .zero
    @State private var positionExportTabs: CGSize = CGSize(width: 0.842, height: 0.175)
    @State private var positionExportProperty: CGSize = CGSize(width: 0.842, height: 0.37)
    @State private var positionExportControl: CGSize = CGSize(width: 0.842, height: 0.58)
    
    
    // Animation
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var showers: [Binding<Bool>] = []
    @State private var isShowExportTabs: Bool = false
    @State private var isShowExportProperty: Bool = false
    @State private var isShowExportControl: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: String(localized: "Video grabbing settings"), caption: String(localized: "To select a grabbing type, select options in the Export Properties panel."))
            
            VStack {
                Text(String(localized: "Select the grabbing tab. Then select the export location and settings. To start the process, press the button on the control panel."))
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
                    .magnification(title: "Export Tabs", scale: .zero, size: CGSize(width: imageSize.width * 0.225, height: imageSize.height * 0.1), shape: magnificationShape, position: positionExportTabs, isShow: $isShowExportTabs)
                    .magnification(title: "Export Properties", scale: .zero, size: CGSize(width: imageSize.width * 0.225, height: imageSize.height * 0.25), shape: magnificationShape, position: positionExportProperty, alignment: .leading, isShow: $isShowExportProperty)
                    .magnification(title: "Export controls", scale: .zero, size: CGSize(width: imageSize.width * 0.225, height: imageSize.height * 0.13), shape: magnificationShape, position: positionExportControl, alignment: .leading, isShow: $isShowExportControl)
                    .onAppear {
                        showers = [$isShowExportTabs,
                                   $isShowExportProperty,
                                   $isShowExportControl]
                    }
                    .onReceive(timer) { _ in
                        timerAnimationReceiver(showers: showers, timer: timer)
                    }
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    GrabVideoWorkspaceOverviewPage()
        .frame(width: AppGrid.minWidthOverview, height: AppGrid.minHeightOverview)
}
