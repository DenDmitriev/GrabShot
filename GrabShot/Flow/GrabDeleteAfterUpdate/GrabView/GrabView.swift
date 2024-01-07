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
    
    @AppStorage(DefaultsKeys.viewMode) private var mode: ViewMode = .table
    @EnvironmentObject var coordinator: GrabCoordinator
    @EnvironmentObject var videoStore: VideoStore
    @StateObject var viewModel: GrabModel
    @StateObject var videosModel = VideosModel()
    @Binding var selection: Set<Video.ID>
    
    @State private var showRangePicker: Bool = false
    @State private var progress: Double = .zero
    @State private var actionTitle: String = "Start"
    @State private var isGrabEnable = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Список видео
                Group {
                    if videoStore.videos.isEmpty {
                        DropZoneView(
                            isAnimate: $viewModel.isAnimate,
                            showDropZone: $viewModel.showDropZone,
                            mode: .video
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.bar)
                        .cornerRadius(AppGrid.pt6)
                        .contextMenu { VideosContextMenu(selection: $selection) }
                    } else {
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
                }
                .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate)
                .onDeleteCommand { viewModel.didDeleteVideos(by: selection) }
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
                        get: { videoStore[selection.first ?? viewModel.grabbingID].grabColors },
                        set: { _ in }
                    )
                    StripPreview(colors: colors) {
                        coordinator.present(sheet: .colorStrip(colors: colorsForSelectedVideo()))
                    }
                    .padding(-AppGrid.pt4)
                    .frame(minHeight: 64)
                } label: {
                    Text("Strip")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding([.leading, .bottom, .trailing])
                .disabled(videoStore.videos.first?.grabColors.isEmpty ?? true)
                
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
                            .frame(width: AppGrid.pt80)
                    }
                    .onReceive(videoStore.$isGrabEnable) { isGrabEnable in
                        self.isGrabEnable = isGrabEnable
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
                    .disabled(!isGrabEnable)
                    
                    // Cancel
                    Button { viewModel.cancel() } label: {
                        Text(("Cancel"))
                            .frame(width: AppGrid.pt80)
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
            .onReceive(videoStore.$addedVideo) { video in
                if let video {
                    viewModel.didAppendVideo(video: video)
                }
            }
            .onReceive(videoStore.$period) { period in
                viewModel.updateProgress()
            }
            .frame(minWidth: AppGrid.minWidth, minHeight: AppGrid.minWHeight)
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
    
    private func colorsForSelectedVideo() -> [Color] {
        if selection.isEmpty,
           let id = viewModel.grabbingID {
            selection.insert(id)
        }
        let id = selection.first ?? viewModel.grabbingID
        return videoStore[id].grabColors
    }
}

struct GrabView_Previews: PreviewProvider {
    static var previews: some View {
        let store = VideoStore()
        let scoreController = ScoreController(caretaker: Caretaker())
        let coordinator = GrabCoordinator(videoStore: store, scoreController: scoreController)
        
        GrabView(viewModel: GrabBuilder.build(store: store, score: ScoreController(caretaker: Caretaker())), selection: .constant(Set<Video.ID>()))
            .environmentObject(store)
            .environmentObject(coordinator)
            .previewLayout(.fixed(width: AppGrid.minWidth, height: AppGrid.minWHeight))
    }
}
