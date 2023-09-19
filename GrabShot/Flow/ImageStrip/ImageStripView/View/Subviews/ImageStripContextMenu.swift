//
//  ImageStripContextMenu.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.09.2023.
//

import SwiftUI

struct ImageStripContextMenu: View {
    
    @Binding var showFileExporter: Bool
    @Binding var isFit: Bool
    @EnvironmentObject var imageStrip: ImageStrip
    
    var body: some View {
        Button(isFit ? "Fill" : "Fit") {
            isFit.toggle()
        }
        
        Button("Export") {
            showFileExporter.toggle()
        }
        
        Divider()
        
        Button("Show in Finder", action: {
            showInFinder(url: imageStrip.url) }
        )
    }
    
    private func showInFinder(url: URL?) {
        guard let url else { return }
        FileService.openFile(for: url)
    }
}
