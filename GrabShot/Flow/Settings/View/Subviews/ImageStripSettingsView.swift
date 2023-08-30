//
//  ImageStripSettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripSettingsView: View {
    
    @AppStorage(UserDefaultsService.Keys.stripImageHeight)
    private var stripImageHeight: Double = Grid.pt32
    
    @AppStorage(UserDefaultsService.Keys.colorImageCount)
    private var colorImageCount: Int = 8
    
    var body: some View {
        GroupBox {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Barcode height")
                        Text("The barcode will be extended at the bottom of the image")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    TextField(
                        "Height strip",
                        value: $stripImageHeight, formatter: ResolutionNumberFormatter()
                    )
                    .textFieldStyle(.roundedBorder)
                    .frame(minWidth: Grid.pt24, maxWidth: Grid.pt48)
                    
                    Text("px")
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
                    .frame(width: Grid.pt100)
                    .pickerStyle(.menu)
                }
            }
            .padding(.all, Grid.pt6)
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
