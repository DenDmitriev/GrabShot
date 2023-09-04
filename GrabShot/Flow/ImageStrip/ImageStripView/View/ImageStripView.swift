//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripView: View {
    
    @ObservedObject var viewModel: ImageStripViewModel
    @ObservedObject private var colorMood: ColorMood
    @State var colors: [Color] = []
    @State private var showFileExporter = false
    
    @AppStorage(UserDefaultsService.Keys.stripImageHeight)
    private var stripImageHeight: Double = Grid.pt32
    
    @AppStorage(UserDefaultsService.Keys.colorImageCount)
    private var colorImageCount: Int = 8
    
    init(viewModel: ImageStripViewModel) {
        self.viewModel = viewModel
        colorMood = viewModel.imageStrip.colorMood
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: .zero) {
                Image(nsImage: viewModel.imageStrip.nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .frame(maxHeight: .infinity)
                    .onReceive(viewModel.$imageStrip, perform: { item in
                        if item.colors.isEmpty {
                            viewModel.fetchColors()
                        } else {
                            colors = item.colors
                        }
                    })
                    .onReceive(viewModel.imageStrip.$colors, perform: { newColors in
                        colors = newColors
                    })
                    .onReceive(colorMood.$method, perform: { method in
                        viewModel.fetchColors(method: method)
                    })
                    .onReceive(colorMood.$formula, perform: { formula in
                        viewModel.fetchColors(formula: formula)
                    })
                    .onReceive(colorMood.$isExcludeBlack, perform: { isExcludeBlack in
                        viewModel.fetchColorWithFlags(isExcludeBlack: isExcludeBlack, isExcludeWhite: colorMood.isExcludeWhite)
                    })
                    .onReceive(colorMood.$isExcludeWhite, perform: { isExcludeWhite in
                        viewModel.fetchColorWithFlags(isExcludeBlack: colorMood.isExcludeBlack, isExcludeWhite: isExcludeWhite)
                    })
                    .background(.black)

                StripColorPickerView(colors: colors)
                    .frame(height: stripImageHeight)
                    .onChange(of: colors) { newValue in
                        viewModel.imageStrip.colors = newValue
                    }
                    .environmentObject(viewModel.imageStrip)
                
                ImageStripMethodSettings()
                    .environmentObject(colorMood)
                    .padding(.horizontal)
                    .padding(.top)
                
                HStack {
                    Spacer()
                    
                    Button {
                        showFileExporter.toggle()
                    } label: {
                        Text("Export")
                            .frame(width: Grid.pt80)
                    }
                }
                .padding()
            }
            .frame(minWidth: Grid.pt256, minHeight: Grid.pt256)
            .fileExporter(
                isPresented: $showFileExporter,
                document: ImageDocument(),
                contentType: .image,
                defaultFilename: viewModel.imageStrip.exportTitle
            ) { result in
                viewModel.prepareDirectory(with: result, for: viewModel.imageStrip)
                viewModel.export(imageStrip: viewModel.imageStrip)
            }
            .alert(isPresented: $viewModel.showAlert, error: viewModel.error) { localizedError in
                Text(localizedError.localizedDescription)
            } message: { localizedError in
                Text(localizedError.recoverySuggestion ?? "")
            }
        }
    }
}

struct ImageStrip_Previews: PreviewProvider {
    static var previews: some View {
        ImageStripView(
            viewModel: ImageStripViewModel(imageStrip: ImageStrip(
                nsImage: NSImage(
                    systemSymbolName: "photo",
                    accessibilityDescription: nil
                )!,
                url: URL(string: "my.url.com")!))
        )
    }
}
