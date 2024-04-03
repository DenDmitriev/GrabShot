//
//  MetadataVideoView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.01.2024.
//

import SwiftUI
import UniformTypeIdentifiers
import MetadataVideoFFmpeg

struct MetadataVideoView: View {
    
    @Binding var metadata: MetadataVideo?
    @State var frameRate: Double?
    @State var list: [MetadataItem] = []
    @State var selection = Set<MetadataItem.ID>()
    private let pasteboard = NSPasteboard.general
    
    var body: some View {
        VStack {
            Text("Video Details")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
            
            if !list.isEmpty {
                Table(list,  selection: $selection) {
                    TableColumn("Key", value: \.key)
                        .width(min: AppGrid.pt100)
                    
                    TableColumn("Value") { object in
                        Text(object.value)
                            .contextMenu(ContextMenu(menuItems: {
                                Button("Copy") {
                                    copyToClipboard(text: object.description)
                                }
                            }))
                    }
                    .width(min: AppGrid.pt128)
                }
                .cornerRadius(AppGrid.pt6)
                .copyable(list.filter({ selection.contains($0.id) }))
            } else {
                placeholder
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            loadMetadata(metadata)
        }
        .onChange(of: metadata) { newMetadata in
            loadMetadata(newMetadata)
        }
        .padding()
    }
    
    var placeholder: some View {
        Text("Metadata not available")
            .font(.title2)
            .foregroundColor(.secondary)
    }
    
    private func loadMetadata(_ metadata: MetadataVideo?) {
        list = buildList(metadata)
    }
    
    private func buildList(_ metadata: MetadataVideo?) -> [MetadataItem] {
        guard let metadata else { return [] }
        var list = [MetadataItem]()
        for key in Key.allCases {
            guard let value = key.value(metadata)
            else { continue }
            list.append(.init(id: key.index, key: key.description, value: value))
        }
        return list
    }
    
    private func copyToClipboard(text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}

#Preview {
    MetadataVideoView(metadata: .constant(.placeholder))
        .frame(width: 300, height: 600)
}
