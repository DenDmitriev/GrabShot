//
//  GrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

struct GrabView: View {
    
    @EnvironmentObject var session: Session
    @ObservedObject private var viewModel: GrabModel
    
    @State private var progress: Double
    @State private var actionTitle: String
    @State private var isShowingStrip = false
    @State private var isEnableGrab = false
    
    init(viewModel: GrabModel) {
        self.viewModel = viewModel
        self.progress = .zero
        self.actionTitle = "Start"
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(spacing: .zero) {
                    VideoTable(
                        viewModel: VideoTableModel(
                            videos: $viewModel.session.videos,
                            grabModel: viewModel
                        ),
                        selection: $viewModel.selection,
                        state: $viewModel.grabState
                    )
                    .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate)
                    .onDeleteCommand {
                        viewModel.didDeleteVideos(by: viewModel.selection)
                    }
                    
                    Divider()
                }
                .padding(.bottom)
                .layoutPriority(1)
                
                // Настройки
                SettingsView(grabState: $viewModel.grabState)
                    .environmentObject(viewModel.session)
                
                // Штрих код
                GroupBox {
                    GeometryReader { reader in
                        let paddin: CGFloat = Grid.pt4
                        ScrollViewReader { proxy in
                            ScrollView(.vertical, showsIndicators: true) {
                                VStack(spacing: 0) {
                                    ForEach(viewModel.session.videos) { video in
                                        StripView(viewModel: StripModel(video: video), showCloseButton: false)
                                            .frame(height: reader.size.height + (paddin * 2))
                                    }
                                }
                                
                            }
                            .onReceive(viewModel.$selection, perform: { selection in
                                guard let index = selection.sorted().last else { return }
                                withAnimation {
                                    proxy.scrollTo(index)
                                }
                            })
                            .onChange(of: viewModel.grabbingID) { grabbed in
                                guard let index = grabbed else { return }
                                withAnimation {
                                    proxy.scrollTo(index)
                                }
                            }
                        }
                        .padding(.all, -paddin)
                    }
                    .frame(minHeight: 64)
                    .overlay(alignment: .trailing) {
                        Button {
                            isShowingStrip.toggle()
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                        }
                        .buttonStyle(.borderless)
                        .frame(width: Grid.pt24, height: Grid.pt24)
                        .background(.regularMaterial)
                        .cornerRadius(Grid.pt4)
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
                        .disabled(viewModel.session.videos.first?.colors?.isEmpty ?? true)
                        .padding()
                    }
                } label: {
                    Text("Strip")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding([.leading, .bottom, .trailing])
                
                
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
            .disabled(session.isCalculating)
            .overlay {
                LoaderView()
                    .hidden(!session.isCalculating)
            }
            .onReceive(session.$videos) { videos in
                viewModel.didAppendVideos(videos: videos)
            }
            .onReceive(session.$period) { period in
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
    }
}

struct GrabView_Previews: PreviewProvider {
    static var previews: some View {
        GrabView(viewModel: GrabModel())
            .environmentObject(Session.shared)
        .previewLayout(.fixed(width: Grid.pt800, height: Grid.pt600))
    }
}
