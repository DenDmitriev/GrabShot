//
//  VideoTableColumnToggleItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.08.2023.
//

import SwiftUI

struct VideoToggleItemView: View {
    
    @EnvironmentObject var viewModel: VideosModel
    @State var hasExportDirectory: Bool = false
    @State var isOn: Bool = false
    @Binding var state: GrabState
    
    var video: Video
    
    var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .onAppear {
            isOn = video.isEnable
        }
        .onReceive(video.$isEnable) { isEnable in
            self.isOn = isEnable
        }
        .onChange(of: isOn) { newValue in
            video.isEnable = newValue
            viewModel.didVideoEnable()
        }
        .disabled(viewModel.isDisabled(by: state))
        .toggleStyle(.checkbox)
        .help("Switch video to grab")
    }
}

struct VideoToggleItemView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        VideoToggleItemView(
            state: Binding<GrabState>.constant(.ready),
            video: Video(url: URL(string: "folder/video.mov")!, store: store)
        )
        .environmentObject(VideosModel(grabModel: GrabModel(store: store)))
    }
}
