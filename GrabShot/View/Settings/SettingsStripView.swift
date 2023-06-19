//
//  SettingsStripView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 21.12.2022.
//

import SwiftUI

struct SettingsStripView: View {
    
    @ObservedObject private var viewModel: SettingsModel
    
    @State private var stripSize: CGSize
    @State private var createStrip: Bool
    @State private var stripCount: Int
    
    init() {
        self.viewModel = SettingsModel()
        self.stripSize = Session.shared.stripSize
        self.createStrip = Session.shared.createStrip
        self.stripCount = Session.shared.stripCount
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
                    .frame(width: 100)
                    .pickerStyle(.menu)
                    //.frame(maxWidth: reader.size.width/3)
                    .onChange(of: stripCount) { newValue in
                        viewModel.updateStripCount(newValue)
                    }
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
                    
                    HStack(spacing: 2) {
                        let width = 50.0
                        
                        TextField("", value: $stripSize.width, formatter: ResolutionNumberFormatter())
                            .frame(width: width)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: stripSize.width) { newValue in
                                viewModel.updateStripResolution(CGSize(width: newValue, height: stripSize.height))
                            }
                        
                        Text("×")
                            .foregroundColor(.gray)
                        
                        TextField("", value: $stripSize.height, formatter: ResolutionNumberFormatter())
                            .frame(width: width)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: stripSize.height) { newValue in
                                viewModel.updateStripResolution(CGSize(width: stripSize.width, height: newValue))
                            }
                        
                        Text("px")
                            .foregroundColor(.gray)
                    }
                }
                .disabled(!createStrip)
            }
            .padding(.all, 6.0)
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
