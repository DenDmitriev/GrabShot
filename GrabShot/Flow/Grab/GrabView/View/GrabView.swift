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
    
    @SceneStorage(DefaultsKeys.viewMode) private var mode: ViewMode = .table
    
    @EnvironmentObject var videoStore: VideoStore
    @StateObject var viewModel: GrabModel
    
    @State var selection = Set<Video.ID>()
    @State private var progress: Double = .zero
    @State private var actionTitle: String = "Start"
    @State private var isShowingStrip = false
    @State private var isGrabEnable = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Список видео
                Group {
                    if videoStore.videos.isEmpty {
                        DropZoneView(isAnimate: $viewModel.isAnimate, showDropZone: $viewModel.showDropZone, mode: .video)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.bar)
                            .cornerRadius(Grid.pt6)
                    } else {
                        Group {
                            let videosModel = VideosModel()
                            switch mode {
                            case .table:
                                VideoTable(
                                    viewModel: videosModel,
                                    selection: $selection,
                                    state: $viewModel.grabState,
                                    sortOrder: $videoStore.sortOrder
                                )
                            case .gallery:
                                VideoGallery(
                                    viewModel: videosModel,
                                    selection: $selection,
                                    state: $viewModel.grabState,
                                    sortOrder: $videoStore.sortOrder
                                )
                            }
                        }
                        .onDeleteCommand {
                            viewModel.didDeleteVideos(by: selection)
                        }
                    }
                }
                .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate)
                .padding(.bottom)
                .layoutPriority(1)
                
                
                // Настройки
                GroupBox {
                    SettingsView(period: $videoStore.period)
                        .disabled(!settingsIsEnable(state: viewModel.grabState))
                } label: {
                    Text("Grab")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding([.leading, .bottom, .trailing])
                
                // Штрих код
                GroupBox {
                    let colors = Binding<[Color]>(
                        get: { videoStore[selection.first ?? viewModel.grabbingID].colors ?? [] },
                        set: { _ in }
                    )
                    StripView(colors: colors, showCloseButton: false)
                        .padding(-Grid.pt4)
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
                    let colors = Binding<[Color]>(
                        get: {
                            if selection.isEmpty,
                            let id = viewModel.grabbingID{
                                selection.insert(id)
                            }
                            let id = selection.first ?? viewModel.grabbingID
                            return videoStore[id].colors ?? []
                        },
                        set: { _ in }
                    )
                    StripView(colors: colors, showCloseButton: true)
                        .frame(
                            minWidth: geometry.size.width / 1.3,
                            maxWidth: geometry.size.width / 1.1,
                            minHeight: Grid.pt256,
                            maxHeight: Grid.pt512
                        )
                }
                .disabled(videoStore.videos.first?.colors?.isEmpty ?? true)
                
                
                // Прогресс
                GrabProgressView(
                    state: $viewModel.grabState,
                    duration: $viewModel.durationGrabbing
                )
                .environmentObject(viewModel.progress)
                .padding(.horizontal)
                
                // Управление
                HStack {
                    Spacer()
                    
                    // Start/Pause/Resume
                    Button {
                        viewModel.grabbingButtonRouter()
                    } label: {
                        Text(viewModel.getTitleForGrabbingButton())
                            .frame(width: Grid.pt80)
                    }
                    .onReceive(videoStore.$isGrabEnable) { isGrabEnable in
                        self.isGrabEnable = isGrabEnable
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isGrabEnable)
                    
                    
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
    
    private func settingsIsEnable(state: GrabState) -> Bool {
        switch state {
        case .ready, .canceled, .complete:
            return true
        case .calculating, .grabbing, .pause:
            return false
        }
    }
}

struct GrabView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        GrabView(viewModel: GrabModel(store: store, score: ScoreController(caretaker: Caretaker())))
            .environmentObject(store)
            .previewLayout(.fixed(width: Grid.minWidth, height: Grid.minWHeight))
    }
}
