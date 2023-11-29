//
//  GrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

struct GrabView: View {
    
    enum ViewMode: String, CaseIterable, Identifiable {
        var id: Self { self }
        case table, gallery
    }
    @SceneStorage("viewMode") private var mode: ViewMode = .table
    
    @EnvironmentObject var videoStore: VideoStore
    @StateObject var viewModel: GrabModel
    
    @State private var progress: Double = .zero
    @State private var actionTitle: String = "Start"
    @State private var isShowingStrip = false
    @State private var isEnableGrab = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Список видео
                switch mode {
                case .table:
                    table
                case .gallery:
                    gallery
                }
                
                // Настройки
                SettingsView(grabState: $viewModel.grabState)
                
                // Штрих код
                GroupBox {
                    StripsView(sortOrder: $videoStore.sortOrder, selection: $videoStore.selection, grabbingId: $viewModel.grabbingID)
                        .frame(minHeight: 64)
                        .overlay(alignment: .trailing) {
                            Button {
                                isShowingStrip.toggle()
                            } label: {
                                Image(systemName: "barcode.viewfinder")
                                    .padding(Grid.pt4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(Grid.pt4)
                            }
                            .buttonStyle(.plain)
                            .padding()
                        }
                } label: {
                    Text("Strip")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding([.leading, .bottom, .trailing])
                .sheet(isPresented: $isShowingStrip) {
                    if let video =  viewModel.getVideoForStripView() {
                        StripView(
                            viewModel: StripModel(video: video),
                            showCloseButton: true
                        )
                        .frame(
                            minWidth: geometry.size.width / 1.3,
                            maxWidth: geometry.size.width / 1.1,
                            minHeight: Grid.pt256,
                            maxHeight: Grid.pt512
                        )
                    }
                }
                .disabled(videoStore.videos.first?.colors?.isEmpty ?? true)
                
                
                // Прогресс
                GrabProgressView(
                    state: $viewModel.grabState,
                    duration: $viewModel.durationGrabbing
                )
                .environmentObject(viewModel.progress)
                .padding(.horizontal)
                
                //  Управление
                HStack {
                    Spacer()
                    
                    // Start/Pause/Resume
                    Button {
                        viewModel.grabbingButtonRouter()
                    } label: {
                        Text(viewModel.getTitleForGrabbingButton())
                            .frame(width: Grid.pt80)
                    }
                    .onReceive(viewModel.$isEnableGrab) { isEnableGrab in
                        self.isEnableGrab = isEnableGrab
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isEnableGrab)
                    
                    
                    // Cancel
                    Button {
                        viewModel.cancel()
                    } label: {
                        Text(("Cancel"))
                            .frame(width: Grid.pt80)
                    }
                    .keyboardShortcut(.cancelAction)
                    .disabled(!viewModel.isEnableCancelButton())
                }
                .padding([.leading, .bottom, .trailing])
            }
            .disabled(videoStore.isCalculating)
            .overlay {
                LoaderView()
                    .hidden(!videoStore.isCalculating)
            }
            .onReceive(videoStore.$videos) { videos in
                viewModel.didAppendVideos(videos: videos)
            }
            .onReceive(videoStore.$period) { period in
                viewModel.updateProgress()
            }
            .alert(isPresented: $viewModel.showAlert, error: viewModel.error) { _ in
                Button("OK", role: .cancel) {
                    print("alert dismiss")
                }
            } message: { error in
                Text(error.recoverySuggestion ?? "")
            }
            .frame(minWidth: Grid.minWidth, minHeight: Grid.minWHeight)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                DisplayModePicker(mode: $mode)
            }
        }
    }
    
    var table: some View {
        VideoTable(
            viewModel: VideosModel(grabModel: viewModel),
            selection: $videoStore.selection,
            state: $viewModel.grabState,
            sortOrder: $videoStore.sortOrder
        )
        .environmentObject(viewModel)
        .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate)
        .onDeleteCommand {
            viewModel.didDeleteVideos(by: videoStore.selection)
        }
        .padding(.bottom)
        .layoutPriority(1)
    }
    
    var gallery: some View {
        VideoGallery(
            viewModel: VideosModel(grabModel: viewModel),
            selection: $videoStore.selection,
            state: $viewModel.grabState,
            sortOrder: $videoStore.sortOrder
        )
        .padding()
        .environmentObject(viewModel)
        .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate)
        .onDeleteCommand {
            viewModel.didDeleteVideos(by: videoStore.selection)
        }
        .padding(.bottom)
        .layoutPriority(1)
    }
}

struct GrabView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        GrabView(viewModel: GrabModel(store: store))
            .environmentObject(store)
            .previewLayout(.fixed(width: Grid.minWidth, height: Grid.minWHeight))
    }
}
