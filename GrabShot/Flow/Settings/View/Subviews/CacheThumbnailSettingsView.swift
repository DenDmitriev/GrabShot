//
//  CacheThumbnailSettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2023.
//

import SwiftUI

struct CacheThumbnailSettingsView: View {
    
    @EnvironmentObject var viewModel: SettingsModel
    @State var cacheJpegSize: FileSize?
    @Binding var showAlert: Bool
    @Binding var message: String?
    @State var isDisable: Bool = false
    @State var isProgress: Bool = false
    
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text("Cache for video thumbnails")
                    Text("Automatically cleared after closing the application")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button {
                    isDisable = true
                    isProgress = true
                    FileService.clearJpegCache { result in
                        isProgress = false
                        switch result {
                        case .success:
                            if let cacheJpegSize {
                                let title = NSLocalizedString("Deleted", comment: "Alert title")
                                message = title + " " + cacheJpegSize.description
                                showAlert = true
                            }
                            
                            
                            if let fileSize = viewModel.getJpegCacheSize() {
                                cacheJpegSize = fileSize
                                isDisable = getButtonDisable()
                            }
                        case .failure(let failure):
                            message = failure.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    if isProgress {
                        HStack(spacing: Grid.pt4) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Cleaning...")
                        }
                    } else {
                        if let cacheJpegSize,
                           cacheJpegSize.size > 0 {
                            Text("Clear \(cacheJpegSize.description)")
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
            .padding(.all, Grid.pt6)
        } label: {
            Text("Cache settings")
        }
        .onAppear {
            if let fileSize = viewModel.getJpegCacheSize() {
                cacheJpegSize = fileSize
            }
        }
    }
    
    private func getButtonDisable() -> Bool {
        cacheJpegSize == nil || cacheJpegSize?.size == .zero
    }
}

#Preview {
    CacheThumbnailSettingsView(showAlert: .constant(false), message: .constant(nil))
        .environmentObject(SettingsModel())
}
