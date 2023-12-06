//
//  MetadataFormatView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.12.2023.
//

import SwiftUI

struct MetadataFormatView: View {
    
    @Binding var metadata: MetadataVideo?
    
    var body: some View {
        if let metadata {
            ScrollView {
                VStack(alignment: .leading, content: {
                    MetadataTable(title: "Format", dictionary: metadata.format.dictionary)
                    
                    if let formatTags = metadata.format.tags {
                        MetadataTable(title: "Tags", dictionary: formatTags.dictionary)
                    }
                    
                })
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        } else {
            placeholder
        }
        
    }
    
    var placeholder: some View {
        Text("Format not available")
            .font(.title2)
            .foregroundColor(.secondary)
    }
}

#Preview {
    MetadataFormatView(metadata: .constant(.placeholder ?? nil))
}
