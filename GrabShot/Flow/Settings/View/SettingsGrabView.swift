//
//  SettingsGrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsGrabView: View {
    
    @EnvironmentObject var videoStore: VideoStore
    @EnvironmentObject var viewModel: SettingsModel
    
    @AppStorage(DefaultsKeys.openDirToggle)
    private var openDirToggle: Bool = true
    
    @AppStorage(DefaultsKeys.quality)
    private var quality: Double = 0.7
    
    @AppStorage(DefaultsKeys.createFolder)
    private var createFolder: Bool = true
    
    @AppStorage(DefaultsKeys.exportGrabbingImageFormat)
    private var exportGrabbingImageFormat: FileService.Format = .jpeg
    
    var body: some View {
        GroupBox {
            VStack {
                HStack(spacing: AppGrid.pt32) {
                    VStack(alignment: .leading) {
                        Text("Сompression factor")
                        
                        Text("Grab shots compression ratio")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text(quality, format: .percent)
                            .foregroundColor(.gray)
                            .frame(width: AppGrid.pt48)
                        
                        Slider(value: $quality, in: 0...1, step: 0.1)
                    }
                }
                
                Divider()
                
                HStack(spacing: AppGrid.pt32) {
                    VStack(alignment: .leading) {
                        Text("Export grabbed image file format")
                        
                        Text("File type to export when grabbing video")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Picker("", selection: $exportGrabbingImageFormat) {
                        ForEach(FileService.Format.allCases) { format in
                            Text(format.fileExtension)
                                .tag(format)
                        }
                    }
                    .frame(width: AppGrid.pt120)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Open folder")
                        
                        Text("Open folder with shots after capture")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $openDirToggle)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
            .padding(.all, AppGrid.pt6)
        } label: {
            Text("Grab settings")
        }
        .padding(.all)
        
        Spacer()
    }
}

struct SettingsGrabView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        SettingsGrabView()
            .environmentObject(SettingsModel())
            .environmentObject(store)
    }
}
