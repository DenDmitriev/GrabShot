//
//  MetadataStreamView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.12.2023.
//

import SwiftUI
import MetadataVideoFFmpeg

struct MetadataStreamView: View {
    
    @State var stream: StreamMetadata?
    
    var body: some View {
        if let stream {
            ScrollView {
                VStack(alignment: .leading, spacing: AppGrid.pt16) {
                    MetadataTable(title: "Video stream", dictionary: stream.dictionary)
                    
                    if let streamTags = stream.tags {
                        MetadataTable(title: "Stream Tags", dictionary: streamTags.dictionary)
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        } else {
            placeholder
        }
    }
    
    var placeholder: some View {
        Text("Stream not available")
            .font(.title2)
            .foregroundColor(.secondary)
    }
}

#Preview {
    MetadataStreamView(stream: MetadataVideo.placeholder?.streams.first ?? nil)
}
