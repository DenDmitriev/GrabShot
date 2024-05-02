//
//  ImageStripMethodSettings.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import SwiftUI
import DominantColors

struct ImageStripMethodSettings: View {
    
    @Environment(\.openURL) private var openURL
    @EnvironmentObject var colorMood: ColorMood
    @State private var colorExtractMethodDescription: String = "Method description"
    @State private var colorExtractFormulaDescription: String = "Formula description"
    
    var body: some View {
        GroupBox("Color extraction") {
            HStack {
                VStack {
                    HStack {
                        VStack(spacing: .zero) {
                            Text("Method")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(NSLocalizedString(colorExtractMethodDescription, comment: "Description"))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .onReceive(colorMood.$method) { method in
                                    colorExtractMethodDescription = method.description
                                }
                        }
                        Spacer()
                        Picker("", selection: $colorMood.method) {
                            ForEach(ColorExtractMethod.allCases, id: \.self) { method in
                                Text(NSLocalizedString(method.name, comment: "Title"))
                            }
                        }
                        .frame(maxWidth: AppGrid.pt192)
                    }
                    
                    Divider()
                    
                    HStack(spacing: AppGrid.pt16) {
                        VStack {
                            Text("Algorithm")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(NSLocalizedString(colorExtractFormulaDescription, comment: "Description"))
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .onReceive(colorMood.$formula) { formula in
                                    colorExtractFormulaDescription = formula.description
                                }
                        }
                        
                        Spacer()
                        
                        Picker("", selection: $colorMood.formula) {
                            ForEach(DeltaEFormula.allCases, id: \.self) { formula in
                                Text(NSLocalizedString(formula.name, comment: "Title"))
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Button {
                            if let url = URL(string: "https://en.wikipedia.org/wiki/Color_difference") {
                                openURL(url)
                            }
                        } label: {
                            Image(systemName: "questionmark")
                        }
                    }
                    .disabled(!(colorMood.method == .dominationColor))
                    
                    HStack(spacing: AppGrid.pt16) {
                        VStack {
                            Text("Flags")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Additional options")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        
                        Toggle(isOn: $colorMood.isExcludeBlack) {
                            Text("Exclude black color")
                        }
                        
                        Toggle(isOn: $colorMood.isExcludeWhite) {
                            Text("Exclude white color")
                        }
                        
                        Toggle(isOn: $colorMood.isExcludeGray) {
                            Text("Exclude gray color")
                        }
                    }
                    .disabled(!(colorMood.method == .dominationColor))
                }
            }
            .padding(AppGrid.pt8)
        }
    }
}

struct ImageStripMethodSettings_Previews: PreviewProvider {
    static var previews: some View {
        ImageStripMethodSettings()
            .environmentObject(ColorMood())
    }
}
