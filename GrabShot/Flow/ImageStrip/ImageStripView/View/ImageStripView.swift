//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStripView: View {
    
    @ObservedObject var viewModel: ImageStripViewModel
    @State var colors: [Color]
    @State private var showFileExporter = false
    
    @AppStorage(UserDefaultsService.Keys.stripImageHeight)
    private var stripImageHeight: Double = Grid.pt32
    
    @AppStorage(UserDefaultsService.Keys.colorImageCount)
    private var colorImageCount: Int = 8
    
    init(viewModel: ImageStripViewModel) {
        self.viewModel = viewModel
        self.colors = []
//        self._colors = Binding<[Color]>(
//            get: { viewModel.imageStrip.colors },
//            set: { colors in viewModel.imageStrip.colors = colors }
//        )
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
                        viewModel.fetchColors(count: count)
                    }
                    .onReceive(viewModel.$imageStrip, perform: { item in
                        if item.colors.isEmpty {
                            viewModel.fetchColors(count: colorImageCount)
                        }
                        colors = item.colors
                    })
                    .background(.black)
                
                StripPalleteView(colors: $colors)
                    .frame(height: stripImageHeight)
                    .onChange(of: colors) { newValue in
                        viewModel.imageStrip.colors = colors
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
