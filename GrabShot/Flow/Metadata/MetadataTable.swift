//
//  MetadataTable.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.12.2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct MetadataTable<Key: Keyable>: View {
    
    struct Metadata: Identifiable {
        let id: Int
        let key: String
        let value: String
    }
    
    var title: String
    var data: [Metadata]
    
    @State var selection = Set<Metadata.ID>()
    
    private let pasteboard = NSPasteboard.general
    
    init(title: String, dictionary: [Key: String?]) {
        self.title = title
        self.data = dictionary.compactMap({ object -> MetadataTable<Key>.Metadata? in
            guard object.value != nil,
                  let value = object.value
            else {
                return nil
            }
            return Metadata(id: object.key.index, key: object.key.description, value: value)
        })
    }
    
    var body: some View {
        if !data.isEmpty {
            VStack {
                Text(title)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Table(
                    data.sorted(using: KeyPathComparator(\.id, order: .forward)),
                    selection: $selection
                ) {
                    TableColumn("Key", value: \.key)
                        .width(min: Grid.pt100, max: Grid.pt128)
                    
                    TableColumn("Value") { object in
                        Text(object.value)
                            .contextMenu(ContextMenu(menuItems: {
                                Button("Copy") {
                                    copyToClipboard(text: object.value)
                                }
                            }))
                    }
                    .width(min: Grid.pt128, max: Grid.pt512)
                }
                .frame(height: CGFloat(data.count + 1) * 24 + 18)
                .cornerRadius(Grid.pt6)
            }
        } else {
            Text(title + " " + "is empty")
        }
    }
    
    private func copyToClipboard(text: String) {
        pasteboard.setString(text, forType: .string)
    }
}

#Preview("MetadataTable") {
    MetadataTable(title: "Metadata", dictionary: MetadataVideo.placeholder!.format.dictionary)
}
