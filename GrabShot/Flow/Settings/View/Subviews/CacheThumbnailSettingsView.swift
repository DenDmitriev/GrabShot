//
//  CacheThumbnailSettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2023.
//

import SwiftUI
import MetadataVideoFFmpeg

struct CacheThumbnailSettingsView: View {
    
    @EnvironmentObject var viewModel: SettingsModel
    @State var cacheSize: FileSize?
    @Binding var showAlert: Bool
    @Binding var message: String?
    @State var isDisable: Bool = false
    @State var isProgress: Bool = false
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text(String(localized: "Cache for video", comment: "Title"))
                    Text("Automatically cleared after closing the application")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button {
                    isDisable = true
                    isProgress = true
                    FileService.clearCache { result in
                        isProgress = false
                        switch result {
                        case .success:
                            if let cacheSize {
                                let title = NSLocalizedString("Deleted", comment: "Alert title")
                                message = title + " " + cacheSize.formatted(.fileSize)
                                showAlert = true
                            }
                            
                            
                            if let fileSize = viewModel.getCacheSize() {
                                cacheSize = fileSize
                                isDisable = getButtonDisable()
                            }
                        case .failure(let failure):
                            message = failure.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    if isProgress {
                        HStack(spacing: AppGrid.pt4) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Cleaning...")
                        }
                    } else {
                        if let cacheSize,
                           cacheSize.size > 0 {
                            Text("Clear \(cacheSize.formatted(.fileSize))")
                        } else {
                            Text("Clear")
                        }
                    }
                }
                .onAppear {
                    isDisable = getButtonDisable()
                }
                .disabled(isDisable)
            }
            .padding(.all, AppGrid.pt6)
        } label: {
            Text("Cache settings")
        }
        .onAppear {
            var cacheSize: FileSize = .init(size: 0.0, unit: .byte)
            if let fileSizeJpeg = viewModel.getJpegCacheSize() {
                cacheSize += fileSizeJpeg
            }
            if let fileSizeVideo = viewModel.getVideoCacheSize() {
                cacheSize += fileSizeVideo
            }
            self.cacheSize = cacheSize.optimal()
        }
    }
    
    private func getButtonDisable() -> Bool {
        cacheSize == nil || cacheSize?.size == .zero
    }
}

#Preview {
    CacheThumbnailSettingsView(showAlert: .constant(false), message: .constant(nil))
        .environmentObject(SettingsModel())
}
