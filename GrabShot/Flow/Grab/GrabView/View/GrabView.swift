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
    @State private var actionLog: String
    @State private var isShowingStrip: Bool
    
    init() {
        self.viewModel = GrabModel()
        self.progress = 0.0
        self.actionLog = "Start"
        self.isShowingStrip = false
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                VStack {
                    VStack(spacing: 0) {
                        VideoTable(
                            viewModel: VideoTableModel(videos: viewModel.session.videos),
                            selection: $viewModel.selection
                        )
                        .onDrop(of: ["public.file-url"], delegate: VideoDropDelegate())
                        .onDeleteCommand(perform: {
                            viewModel.delete(for: viewModel.selection)
                        })
                        
                        Divider()
                    }
                    .padding(.bottom)
                    .layoutPriority(1)
                    
                    //Настройки
                    SettingsView()
                        .environmentObject(viewModel.session)
                    
                    //Strip
                    GroupBox {
                        ZStack {
                            //Strip view
                            GeometryReader { reader in
                                let paddin: CGFloat = 4.0
                                ScrollViewReader { proxy in
                                    ScrollView(.vertical, showsIndicators: true) {
                                        VStack(spacing: 0) {
                                            ForEach(viewModel.session.videos) { video in
                                                StripView(viewModel: StripModel(video: video))
                                                    .frame(height: reader.size.height + (paddin * 2))
                                            }
                                        }
                                        
                                    }
                                    .onChange(of: viewModel.selection) { selection in
                                        guard let index = selection else { return }
                                        withAnimation {
                                            proxy.scrollTo(index)
                                        }
                                    }
                                    .onChange(of: viewModel.grabbingID) { grabed in
                                        guard let index = grabed else { return }
                                        withAnimation {
                                            proxy.scrollTo(index)
                                        }
                                    }
                                }
                                .padding(.all, -paddin)
                            }
                            
                            //Settings strip
                            HStack {
                                Spacer()
                                
                                Button {
                                    if viewModel.selection == nil {
                                        viewModel.selection = viewModel.grabbingID
                                    }
                                    isShowingStrip.toggle()
                                    print("view strip image action")
                                } label: {
                                    Image(systemName: "barcode.viewfinder")
                                }
                                .sheet(isPresented: $isShowingStrip) {
                                    StripView(viewModel: StripModel(video: viewModel.session.videos.first(where: { $0.id == viewModel.selection })))
                                        .frame(width: 256, height: 256)
                                }
                                .disabled(viewModel.session.videos.first?.colors?.isEmpty ?? true)
                                
                            }
                            .padding(.all, 8.0)
                        }
                    } label: {
                        Text("Strip")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding([.leading, .bottom, .trailing])
                    
                    
                    //Прогресс и управление
                    VStack {
                        HStack(alignment: .center) {
                            
                            ProgressView(value: viewModel.passedShots, total: viewModel.totalShots) {
                                Text(viewModel.status.log)
                                    .foregroundColor(Color.gray)
                            }
                            .padding(.trailing, 8.0)
                            .progressViewStyle(.linear)
                            
                            
                            HStack {
                                Button(actionLog) {
                                    switch session.isGrabbing {
                                    case true:
                                        viewModel.pause()
                                    case false:
                                        viewModel.start()
                                    }
                                }
                                .onReceive(session.$isGrabbing, perform: { isGrabing in
                                    let title = NSLocalizedString(isGrabing ? "Pause" : "Start", comment: "button")
                                    actionLog = title
                                })
                                .disabled(viewModel.session.videos.isEmpty)
                                
                                Button("Cancel") {
                                    print("Cancel")
                                    viewModel.cancel()
                                }
                                .disabled(!session.isGrabbing)
                            }
                        }
                    }
                    .padding([.leading, .bottom, .trailing])
                }
                .disabled(session.isCalculating)
                
                LoaderView()
                    .hidden(!session.isCalculating)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

//struct GrabView_Previews: PreviewProvider {
//    static var previews: some View {
//        GrabView()
//            .environmentObject(Session.shared)
//        .previewLayout(.fixed(width: 600, height: 400))
//    }
//}
