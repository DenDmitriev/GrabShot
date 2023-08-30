//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripView: View {
    
    @ObservedObject var viewModel: ImageStripViewModel
    @State var colors: [Color] = []
    @State var hasColors = false
    @State private var showFileExporter = false
    
    @AppStorage(UserDefaultsService.Keys.stripImageHeight)
    private var stripImageHeight: Double = Grid.pt32
    
    @AppStorage(UserDefaultsService.Keys.colorImageCount)
    private var colorImageCount: Int = 8
    
    init(viewModel: ImageStripViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: .zero) {
                Image(nsImage: viewModel.imageStrip.nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width)
                    .frame(maxHeight: .infinity)
                    .onChange(of: colorImageCount) { count in
                        hasColors = false
                        colors = viewModel.colors(nsImage: viewModel.imageStrip.nsImage, count: colorImageCount)
                        hasColors = true
                    }
                    .onChange(of: viewModel.imageStrip, perform: { imageStrip in
                        if imageStrip.colors.count != colorImageCount {
                            colors = viewModel.colors(nsImage: imageStrip.nsImage, count: colorImageCount)
                            viewModel.imageStrip.colors = colors
                            hasColors = true
                        } else {
                            colors = imageStrip.colors
                            hasColors = true
                        }
                    })
                    .onAppear {
                        if viewModel.imageStrip.colors.count != colorImageCount {
                            colors = viewModel.colors(nsImage: viewModel.imageStrip.nsImage, count: colorImageCount)
                            viewModel.imageStrip.colors = colors
                            hasColors = true
                        } else {
                            colors = viewModel.imageStrip.colors
                            hasColors = true
                        }
                    }
                    .background(.black)
                
                if hasColors {
                    StripPalleteView(colors: $colors)
                        .frame(height: stripImageHeight)
                        .onChange(of: colors) { colors in
                            viewModel.imageStrip.colors = colors
                        }
                }
                
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
