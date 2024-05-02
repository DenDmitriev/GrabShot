//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripView: View {
    
    @EnvironmentObject var viewModel: ImageStripViewModel
    @StateObject var colorMood: ColorMood
    @State var colors: [Color] = []
    @State private var showFileExporter = false
    @State private var isFit = true
    @State private var size: CGSize = .zero
    
    @AppStorage(DefaultsKeys.stripImageHeight)
    private var stripImageHeight: Double = AppGrid.pt32
    
    @AppStorage(DefaultsKeys.colorImageCount)
    private var colorImageCount: Int = 8
    
    var body: some View {
        VSplitView {
            AsyncImage(url: viewModel.imageStrip.url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: isFit ? .fit : .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(minHeight: AppGrid.pt128, maxHeight: .infinity)
                    .background(.black)
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
                        viewModel.fetchColorWithFlags(isExcludeBlack: isExcludeBlack, isExcludeWhite: colorMood.isExcludeWhite, isExcludeGray: colorMood.isExcludeGray)
                    })
                    .onReceive(colorMood.$isExcludeWhite, perform: { isExcludeWhite in
                        viewModel.fetchColorWithFlags(isExcludeBlack: colorMood.isExcludeBlack, isExcludeWhite: isExcludeWhite, isExcludeGray: colorMood.isExcludeGray)
                    })
                    .onReceive(colorMood.$isExcludeGray, perform: { isExcludeGray in
                        viewModel.fetchColorWithFlags(isExcludeBlack: colorMood.isExcludeBlack, isExcludeWhite: colorMood.isExcludeWhite, isExcludeGray: isExcludeGray)
                    })
            } placeholder: {
                Image(systemName: "photo")
                    .symbolVariant(.fill)
                    .font(.system(size: AppGrid.pt128))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.gray)
                    .background(background)
            }
            .contextMenu {
                ImageStripContextMenu(showFileExporter: $showFileExporter, isFit: $isFit)
                    .environmentObject(viewModel.imageStrip)
            }
            .overlay(alignment: .bottomTrailing) {
                Button {
                    isFit.toggle()
                } label: {
                    Image(systemName: isFit ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                        .padding(AppGrid.pt4)
                        .background(.ultraThinMaterial)
                        .cornerRadius(AppGrid.pt4)
                }
                .buttonStyle(.borderless)
                .padding(AppGrid.pt16)
            }
            
            StripColorPickerView(colors: colors)
                .frame(height: AppGrid.pt80)
                .onChange(of: colors) { newValue in
                    viewModel.imageStrip.colors = newValue
                }
                .environmentObject(viewModel.imageStrip)
            
            ScrollView {
                ImageStripMethodSettings()
                    .environmentObject(colorMood)
                    .padding(.horizontal)
                    .padding(.top)
                
            }
            
            HStack {
                Spacer()
                
                Button {
                    showFileExporter.toggle()
                } label: {
                    Text("Export")
                        .frame(width: AppGrid.pt80)
                }
                .fileExporter(
                    isPresented: $showFileExporter,
                    document: ImageDocument(),
                    contentType: .image,
                    defaultFilename: viewModel.imageStrip.exportTitle
                ) { result in
                    viewModel.prepareDirectory(with: result, for: viewModel.imageStrip)
                    viewModel.export(imageStrip: viewModel.imageStrip)
                }
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showAlert, error: viewModel.error) { localizedError in
            Text(localizedError.localizedDescription)
        } message: { localizedError in
            Text(localizedError.recoverySuggestion ?? "")
        }
        .frame(minWidth: AppGrid.pt256, minHeight: AppGrid.pt256)
        .readSize(onChange: { size in
            self.size = size
        })
    }
    
    var background: some View {
        Rectangle()
            .fill(.black)
    }
}

#Preview {
    let imageStrip = ImageStrip.placeholder
    let viewModel = ImageStripViewModel(imageStrip: imageStrip, imageRenderService: ImageRenderService())
    
    return ImageStripView(colorMood: viewModel.imageStrip.colorMood)
        .environmentObject(viewModel)
}
