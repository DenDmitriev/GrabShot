//
//  ContentView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var scoreController: ScoreController
    @EnvironmentObject var coordinator: TabCoordinator
    
    var body: some View {
        TabCoordinatorView(coordinator: coordinator)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let videoStore = VideoStore()
        let imageStore = ImageStore()
        let scoreController = ScoreController(caretaker: Caretaker())
        
        ContentView()
            .environmentObject(scoreController)
            .environmentObject(videoStore)
            .environmentObject(imageStore)
    }
}
