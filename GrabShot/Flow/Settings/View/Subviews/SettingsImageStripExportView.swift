//
//  SettingsImageStripExportView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 28.03.2024.
//

import SwiftUI

struct SettingsImageStripExportView: View {
    @AppStorage(DefaultsKeys.exportImageStripFormat)
    private var exportImageStripFormat: FileService.Format = .jpeg
    
    @AppStorage(DefaultsKeys.exportImageStripCompressionFactor)
    private var exportImageStripCompressionFactor: Double = 0.0
    
    var body: some View {
        GroupBox {
            VStack {
                HStack(spacing: AppGrid.pt32) {
                    VStack(alignment: .leading) {
                        Text("Сompression factor")
                        
                        Text("The ratio ranges from 0 (lowest) to 100% (highest)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text(exportImageStripCompressionFactor, format: .percent)
                            .foregroundColor(.gray)
                            .frame(width: AppGrid.pt48)
                        
                        Slider(value: $exportImageStripCompressionFactor, in: 0...1, step: 0.1)
                    }
                }
                
                Divider()
                
                HStack(spacing: AppGrid.pt32) {
                    VStack(alignment: .leading) {
                        Text("Export file format")
                        
                        Text("File type to export when extracting color from an image")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("", selection: $exportImageStripFormat) {
                        ForEach(FileService.Format.allCases) { format in
                            Text(format.fileExtension)
                                .tag(format)
                        }
                    }
                    .frame(width: AppGrid.pt120)
                }
            }
            .padding(.all, AppGrid.pt6)
        } label: {
            Text("Image export settings")
        }
    }
}

#Preview {
    SettingsImageStripExportView()
}
