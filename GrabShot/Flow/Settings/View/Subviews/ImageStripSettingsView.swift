//
//  ImageStripSettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripSettingsView: View {
    
    @AppStorage(DefaultsKeys.stripImageHeight)
    private var stripImageHeight: Double = AppGrid.pt32
    
    @AppStorage(DefaultsKeys.colorImageCount)
    private var colorImageCount: Int = 8
    
    @AppStorage(DefaultsKeys.createStripBorder)
    private var createStripBorder: Bool = false
    
    @AppStorage(DefaultsKeys.stripBorderWidth)
    private var stripBorderWidth: Int = 5
    
    @AppStorage(DefaultsKeys.stripBorderColor)
    private var stripBorderColor: Color = .white
    
    var body: some View {
        GroupBox {
            VStack {
                HStack(spacing: AppGrid.pt16) {
                    VStack(alignment: .leading) {
                        Text("Barcode height")
                        Text("The barcode will be extended at the bottom of the image")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack(spacing: AppGrid.pt4) {
                            TextField(
                                "Height strip",
                                value: $stripImageHeight, formatter: ResolutionNumberFormatter()
                            )
                            .textFieldStyle(.roundedBorder)
                            .frame(minWidth: AppGrid.pt24, maxWidth: AppGrid.pt48)
                            
                            Text("px")
                        }
                    }
                }
                
                Divider()
                
                HStack(spacing: AppGrid.pt16) {
                    VStack(alignment: .leading) {
                        Text("Barcode border")
                        Text("The barcode will be extended at the bottom of the image")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    
                    Toggle("", isOn: $createStripBorder)
                        .toggleStyle(.switch)
                    
                    ColorPicker("Color", selection: $stripBorderColor)
                        .disabled(!createStripBorder)
                    
                    HStack(spacing: AppGrid.pt4) {
                        Text("Width")
                        TextField(
                            "Width border",
                            value: $stripBorderWidth, formatter: BorderNumberFormatter()
                        )
                        .textFieldStyle(.roundedBorder)
                        .frame(minWidth: AppGrid.pt24, maxWidth: AppGrid.pt48)
                        
                        Text("px")
                    }
                    .disabled(!createStripBorder)
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Number of colors")
                        Text("Sampling average colors from an image")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Picker(selection: $colorImageCount, label: Text("")) {
                        ForEach(1...8, id: \.self) { count in
                            StripCountView(count: count)
                        }
                    }
                    .frame(width: AppGrid.pt100)
                    .pickerStyle(.menu)
                }
            }
            .padding(.all, AppGrid.pt6)
        } label: {
            Text("Strip settings for image")
        }
    }
}

struct ImageStripSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ImageStripSettingsView()
    }
}
