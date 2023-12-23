//
//  MetadataView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.12.2023.
//

import SwiftUI
import MetadataVideoFFmpeg

struct MetadataView: View {
    @Environment(\.dismiss) private var dismiss
    @State var metadata: MetadataVideo?
    @State var selection: Int = -1
    
    var body: some View {
        if let metadata {
            NavigationView {
                List(selection: $selection) {
                    Section {
                        NavigationLink {
                            MetadataFormatView(metadata: $metadata)
                        } label: {
                            Text("Format")
                                .padding(.leading)
                        }
                        .tag(-1)
                    } header: {
                        Text(NSLocalizedString("File", comment: "Title").uppercased())
                    }
                    
                    Section {
                        ForEach(metadata.streams) { stream in
                            NavigationLink {
                                MetadataStreamView(stream: stream)
                            } label: {
                                Text(titleOfStream(stream: stream))
                                    .padding(.leading)
                            }
                            .tag(indexOfStream(stream: stream) ?? Int.random(in: 0...100))
                        }
                    } header: {
                        Text(NSLocalizedString("Streams", comment: "Title").uppercased())
                    } footer: {
                        Text("\(metadata.streams.count) streams")
                    }
                }
            }
            .frame(minWidth: AppGrid.pt500)
            .frame(minHeight: AppGrid.pt300)
        } else {
            placeholder
        }
    }
    
    var placeholder: some View {
        VStack {
            Text("Metadata not available")
                .font(.title2)
                .foregroundColor(.secondary)

            Button("Dismiss") {
                dismiss()
            }
        }
    }
    
    private func indexOfStream(stream: StreamMetadata) -> Int? {
        guard let metadata else { return nil }
        return metadata.streams.firstIndex(where: { $0.id == stream.id })
    }
    
    private func titleOfStream(stream: StreamMetadata) -> String {
        if let codecType = stream.codecType, let index = stream.index {
            return (index + 1).formatted() + " " + codecType.description
        } else {
            return "Unknown"
        }
    }
}

struct Metadata_Previews: PreviewProvider {
    static var previews: some View {
        MetadataView(metadata: MetadataVideo.placeholder)
            .previewLayout(.fixed(width: 500, height: 600))
    }
}
