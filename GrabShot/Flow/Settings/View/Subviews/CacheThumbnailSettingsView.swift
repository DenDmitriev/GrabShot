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
                    FileService.clearJpegCache { result in
                        switch result {
                        case .success:
                            if let cacheJpegSize {
                                let title = NSLocalizedString("Deleted", comment: "Alert title")
                                message = title + " " + cacheJpegSize.description
                                showAlert = true
                            }
                            
                            
                            if let fileSize = viewModel.getJpegCacheSize() {
                                cacheJpegSize = fileSize
                            }
                        case .failure(let failure):
                            message = failure.localizedDescription
                            showAlert = true
                        }
                    }
                } label: {
                    if let cacheJpegSize,
                       cacheJpegSize.size > 0 {
                        Text("Clear \(cacheJpegSize.description)")
                    } else {
                        Text("Clear")
                    }
                }
                .disabled(cacheJpegSize == nil || cacheJpegSize?.size == .zero)
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
}

#Preview {
    CacheThumbnailSettingsView(showAlert: .constant(false), message: .constant(nil))
        .environmentObject(SettingsModel())
}
