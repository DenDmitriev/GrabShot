//
//  MetadataView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 05.12.2023.
//

import SwiftUI

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
                        Text("File")
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
                        Text("Streams")
                    } footer: {
                        Text("\(metadata.streams.count) streams")
                    }
                }
            }
            .frame(minWidth: Grid.pt500)
            .frame(minHeight: Grid.pt300)
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
    
    private func indexOfStream(stream: MetadataVideo.Stream) -> Int? {
        guard let metadata else { return nil }
        return metadata.streams.firstIndex(where: { $0.id == stream.id })
    }
    
    private func titleOfStream(stream: MetadataVideo.Stream) -> String {
        if let codecType = stream.codecType, let index = stream.index {
            return (index + 1).formatted() + " " + codecType.description
        } else {
            return "Unknown"
        }
    }
}

struct Metadata_Previews: PreviewProvider {
    static var metadata: MetadataVideo? {
        let url = Bundle.main.url(forResource: "metadata", withExtension: "json")
        guard let url else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let metadata = try JSONDecoder().decode(MetadataVideo.self, from: data)
            return metadata
        } catch {
            return nil
        }
        
    }
    
    static var previews: some View {
        MetadataView(metadata: metadata)
            .previewLayout(.fixed(width: 500, height: 600))
    }
}
