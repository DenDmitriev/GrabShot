//
//  VideoStripSettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.08.2023.
//

import SwiftUI

struct VideoStripSettingsView: View {
    
    @EnvironmentObject var viewModel: SettingsModel
    
    @AppStorage(DefaultsKeys.createStrip)
    private var createStrip: Bool = true
    
    @AppStorage(DefaultsKeys.stripWidth)
    private var stripSizeWidth: Double = 1280
    
    @AppStorage(DefaultsKeys.stripHeight)
    private var stripSizeHeight: Double = 128
    
    @AppStorage(DefaultsKeys.stripCount)
    private var stripCount: Int = 5
    
    @AppStorage(DefaultsKeys.stripViewMode)
    private var stripMode: StripMode = .liner
    
    var body: some View {
        GroupBox {
            VStackLayout(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Create strip")
                        
                        Text("Save image to grab folder")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Toggle("", isOn: $createStrip)
                        .onChange(of: createStrip, perform: { newValue in
                            viewModel.updateCreateStripToggle(value: newValue)
                        })
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Number of average colors")
                        Text("Sampling average colors from one grabbed frame")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Picker(selection: $stripCount, label: Text("")) {
                        ForEach(1...8, id: \.self) { count in
                            StripCountView(count: count)
                        }
                    }
                    .frame(width: AppGrid.pt100)
                    .pickerStyle(.menu)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Strip resolution")
                        
                        Text("Image size for video color strip")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    HStack {
                        let width = AppGrid.pt64
                        
                        TextField("", value: $stripSizeWidth, formatter: ResolutionNumberFormatter())
                            .frame(width: width)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("×")
                            .foregroundColor(.gray)
                        
                        TextField("", value: $stripSizeHeight, formatter: ResolutionNumberFormatter())
                            .frame(width: width)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("px")
                    }
                }
                .disabled(!createStrip)
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Stripe mode")
                        Text("Method for creating a stripe")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Picker(selection: $stripMode, label: Text("")) {
                        ForEach(StripMode.allCases) { mode in
                            StripModeView(mode: mode)
                                .tag(mode)
                        }
                    }
                    .frame(width: AppGrid.pt128)
                    .pickerStyle(.menu)
                }
            }
            .padding(.all, AppGrid.pt6)
        } label: {
            Text("Strip settings for video")
        }
    }
}

struct VideoStripSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VideoStripSettingsView()
            .environmentObject(SettingsModel())
    }
}
