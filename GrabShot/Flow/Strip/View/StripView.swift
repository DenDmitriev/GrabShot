//
//  StripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2022.
//

import SwiftUI

struct StripView: View {
    
    @EnvironmentObject var grabModel: GrabModel
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: StripModel
    @State var showCloseButton: Bool
    
    var body: some View {
        HStack(spacing: .zero) {
            ForEach(viewModel.video?.colors ?? [Color.clear], id: \.self) { color in
                Rectangle()
                    .fill(color)
            }
            .animation(.easeInOut, value: viewModel.video?.colors)
        }
        .overlay(alignment: .topTrailing) {
            if showCloseButton {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.app.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Grid.pt24)
                }
                .tint(.white)
                .buttonStyle(.borderless)
                .padding()
            }
        }
    }
}

struct StripView_Previews: PreviewProvider {

    static var previews: some View {

        let videoPreview: Video = {
            let video = Video(url: URL(string: "ABC")!)
            video.colors = [
                Color(red: 0.1, green: 0.9, blue: 0.5),
                Color(red: 0.6, green: 0.1, blue: 0.4),
                Color(red: 0.2, green: 0.5, blue: 0.7),
                Color(red: 0.8, green: 0.5, blue: 0.9)
            ]
            return video
        }()

        StripView(viewModel: StripModel(video: videoPreview), showCloseButton: true)
            .previewLayout(.fixed(width: Grid.pt256, height: Grid.pt256))
            .environmentObject(GrabModel())
    }
}
