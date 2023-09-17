//
//  ImageStripMethodDefaultSettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.09.2023.
//

import SwiftUI
import DominantColors

struct ImageStripMethodDefaultSettingsView: View {
    
    @Environment(\.openURL) private var openURL
    @State private var methodDescription: String = "Method description"
    @State private var formulaDescription: String = "Formula description"
    
    @AppStorage(DefaultsKeys.colorExtractMethod)
    private var method: ColorExtractMethod = .dominationColor
    
    @AppStorage(DefaultsKeys.colorDominantFormula)
    private var formula: DeltaEFormula = .CIE76
    
    @AppStorage(DefaultsKeys.isExcludeBlack)
    var isExcludeBlack: Bool = false
    
    @AppStorage(DefaultsKeys.isExcludeWhite)
    var isExcludeWhite: Bool = false
    
    var body: some View {
        GroupBox("Color extraction") {
            VStack {
                HStack {
                    VStack(spacing: .zero) {
                        Text("Method")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(NSLocalizedString(methodDescription, comment: "Description"))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .onAppear {
                                methodDescription = method.description
                            }
                            .onChange(of: method) { method in
                                methodDescription = method.description
                            }
                    }
                    Spacer()
                    Picker("", selection: $method) {
                        ForEach(ColorExtractMethod.allCases, id: \.self) { method in
                            Text(method.name)
                        }
                    }
                    .frame(maxWidth: Grid.pt192)
                }
                
                
                Divider()
                
                HStack(spacing: Grid.pt16) {
                    VStack {
                        Text("Algorithm")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(NSLocalizedString(formulaDescription, comment: "Description"))
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .onAppear {
                                formulaDescription = formula.description
                            }
                            .onChange(of: formula) { formula in
                                formulaDescription = formula.description
                            }
                    }
                    
                    Spacer()
                    Picker("", selection: $formula) {
                        ForEach(DeltaEFormula.allCases, id: \.self) { formula in
                            Text(formula.name)
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
                .disabled(!(method == .dominationColor))
                
                HStack(spacing: Grid.pt16) {
                    VStack {
                        Text("Flags")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Additional options")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    
                    Spacer()
                    
                    Toggle(isOn: $isExcludeBlack) {
                        Text("Exclude black color")
                    }
                    
                    Toggle(isOn: $isExcludeWhite) {
                        Text("Exclude white color")
                    }
                }
                .disabled(!(method == .dominationColor))
            }
            .padding(.all, Grid.pt6)
        }
        
    }
}


struct ImageStripMethodDefaultSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ImageStripMethodDefaultSettingsView()
    }
}
