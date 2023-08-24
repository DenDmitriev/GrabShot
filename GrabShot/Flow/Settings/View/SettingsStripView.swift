//
//  SettingsStripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsStripView: View {
    
    @ObservedObject private var viewModel: SettingsModel
    
    @AppStorage(UserDefaultsService.Keys.createStrip)
    private var createStrip: Bool = true
    
    @AppStorage(UserDefaultsService.Keys.stripWidth)
    private var stripSizeWidth: Double = 1280
    
    @AppStorage(UserDefaultsService.Keys.stripHeight)
    private var stripSizeHeight: Double = 128
    
    @AppStorage(UserDefaultsService.Keys.stripCount)
    private var stripCount: Int = 5
    
    init() {
        self.viewModel = SettingsModel()
    }
    
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
                    .frame(width: Grid.pt100)
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
                    
                    HStack(spacing: Grid.pt2) {
                        let width = Grid.pt64
                        
                        TextField("", value: $stripSizeWidth, formatter: ResolutionNumberFormatter())
                            .frame(width: width)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("×")
                            .foregroundColor(.gray)
                        
                        TextField("", value: $stripSizeHeight, formatter: ResolutionNumberFormatter())
                            .frame(width: width)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("px")
                            .foregroundColor(.gray)
                    }
                }
                .disabled(!createStrip)
            }
            .padding(.all, Grid.pt6)
        } label: {
            Text("Strip settings")
        }
        .padding(.all)
        
        Spacer()
    }
}

struct SettingsStripView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsStripView()
    }
}
