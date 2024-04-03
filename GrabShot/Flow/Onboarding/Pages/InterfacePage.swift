//
//  InterfacePage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct InterfacePage: View, OnboardingAnimatable {
    @State private var imageSize: CGSize = .zero
    
    // Selections
    private let magnificationShape: some Shape = RoundedRectangle(cornerRadius: AppGrid.pt8)
    @State private var magnificationScale: CGFloat = 1
    @State private var magnificationSize: CGSize = CGSize(width: 100, height: 100)
    @State private var positionTab: CGSize = CGSize(width: 0.587, height: 0.092)
    @State private var positionSettings: CGSize = CGSize(width: 0.92, height: 0.092)
    
    
    // Animation
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var showers: [Binding<Bool>] = []
    @State private var isShowTabs: Bool = false
    @State private var isShowSetting: Bool = false
    
    
    private var columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .center) {
            OverviewTitle(title: "Control panel", caption: "There are workspaces in the application")
            
            Spacer()
            
            VStack {
                HStack {
                    Text("To select a workspace, use the tab navigation bar")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("To change the application settings, click on the gear")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Image("GrabShotOverview")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(AppGrid.pt16)
                    .readSize(onChange: { size in
                        let width = size.width / 8
                        magnificationSize = CGSize(width: width, height: width)
                    })
                    .magnification(title: String(localized: "Tab Navigation Bar"), scale: magnificationScale, size: magnificationSize, shape: magnificationShape, position: positionTab, alignment: .leading, isShow: $isShowTabs)
                    .magnification(title: String(localized: "Settings"), scale: magnificationScale, size: magnificationSize, shape: magnificationShape, position: positionSettings, alignment: .leading, isShow: $isShowSetting)
                    .onAppear {
                        showers = [
                            $isShowTabs,
                            $isShowSetting
                        ]
                    }
                    .onReceive(timer) { _ in
                        timerAnimationReceiver(showers: showers, timer: timer)
                    }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct InterfacePage_Previews: PreviewProvider {
    static var previews: some View {
        InterfacePage()
            .frame(width: 900, height: 600)
    }
}
