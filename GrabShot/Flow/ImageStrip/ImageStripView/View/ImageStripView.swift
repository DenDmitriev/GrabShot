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
    @State private var isFit = true
    
    @AppStorage(DefaultsKeys.stripImageHeight)
    private var stripImageHeight: Double = AppGrid.pt32
    
    @AppStorage(DefaultsKeys.colorImageCount)
    private var colorImageCount: Int = 8
    
    init(viewModel: ImageStripViewModel) {
        self.viewModel = viewModel
        colorMood = viewModel.imageStrip.colorMood
    }
    
    var body: some View {
        GeometryReader { geometry in
            VSplitView {
                AsyncImage(url: viewModel.imageStrip.url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: isFit ? .fit : .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(minHeight: AppGrid.pt128, idealHeight: geometry.size.width / viewModel.aspectRatio(), maxHeight: .infinity)
                        .background(.black)
                        .onReceive(viewModel.$imageStrip, perform: { item in
                            if item.colors.isEmpty {
                                Task {
                                    await viewModel.fetchColors()
                                }
                            } else {
                                colors = item.colors
                            }
                        })
                        .onReceive(viewModel.imageStrip.$colors, perform: { newColors in
                            colors = newColors
                        })
                        .onReceive(colorMood.$method, perform: { method in
                            Task {
                                await viewModel.fetchColors(method: method)
                            }
                        })
                        .onReceive(colorMood.$formula, perform: { formula in
                            Task {
                                await viewModel.fetchColors(formula: formula)
                            }
                        })
                        .onReceive(colorMood.$isExcludeBlack, perform: { isExcludeBlack in
                            Task {
                                await viewModel.fetchColorWithFlags(isExcludeBlack: isExcludeBlack, isExcludeWhite: colorMood.isExcludeWhite)
                            }
                        })
                        .onReceive(colorMood.$isExcludeWhite, perform: { isExcludeWhite in
                            Task {
                                await viewModel.fetchColorWithFlags(isExcludeBlack: colorMood.isExcludeBlack, isExcludeWhite: isExcludeWhite)
                            }
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
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            showFileExporter.toggle()
                        } label: {
                            Text("Export")
                                .frame(width: AppGrid.pt80)
                        }
                    }
                    .padding()
                }
                .frame(width: geometry.size.width)
            }
            .frame(minWidth: AppGrid.pt256, minHeight: AppGrid.pt256)
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
    
    var background: some View {
        Rectangle()
            .fill(.black)
    }
}

struct ImageStrip_Previews: PreviewProvider {

    static let name = NSImage.Name("testImage")
    static let fileUrl = Bundle.main.bundleURL

    static var previews: some View {
        ImageStripView(
            viewModel: ImageStripViewModel(store: ImageStore(), imageStrip: ImageStrip(url: fileUrl))
        )
        .previewLayout(.fixed(width: 700, height: 600))
    }
}
