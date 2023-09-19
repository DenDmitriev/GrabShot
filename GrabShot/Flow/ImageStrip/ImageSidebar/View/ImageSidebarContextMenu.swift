//
//  ImageSidebarContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.09.2023.
//

import SwiftUI

struct ImageSidebarContextMenu: View {
    
    @EnvironmentObject var viewModel: ImageSidebarModel
    @EnvironmentObject var imageStore: ImageStore
    @Binding var selectedItemIds: Set<ImageStrip.ID>
    
    var body: some View {
        Button("Clear") {
            let ids = imageStore.imageStrips.map({ $0.id })
            delete(ids: Set(ids))
        }
        .disabled(imageStore.imageStrips.isEmpty)
    }
    
    private func delete(ids: Set<ImageStrip.ID>) {
        withAnimation {
            viewModel.delete(ids: ids)
            ids.forEach { id in
                selectedItemIds.remove(id)
            }
        }
    }
}
