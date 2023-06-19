//
//  GrabView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

struct GrabView: View {
    
    @ObservedObject private var session: Session
    @ObservedObject private var viewModel: GrabModel
    
    @State private var progress: Double
    @State private var action: String
    @State private var openDirToggle: Bool
    @State private var showStripSheet: Bool
    @State private var isLoading: Bool
    
    init() {
        self.viewModel = GrabModel()
        self.progress = 0.0
        self.action = "Start"
        self.openDirToggle = Session.shared.openDirToggle
        self.session = Session.shared
        self.showStripSheet = false
        self.isLoading = false
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                VStack {

                    VStack(spacing: 0) {
                        
                        VideoTable(viewModel: viewModel)
                            .onAppear {
                                print("onAppear")
                                viewModel.cacalculate(for: .all)
                            }
                            .onChange(of: viewModel.session.videos) { _ in
                                print("onChange")
                                viewModel.cacalculate(for: .all)
                            }
                            .onChange(of: viewModel.isCalculated) { _ in
                                print("onChange calculated complete")
                            }
                            .onDrop(of: ["public.file-url"], delegate: VideoDropDelegate())
                            .onDeleteCommand(perform: {
                                viewModel.delete(for: viewModel.selection)
                            })
                        
                        Divider()
                    }
                    .padding(.bottom)
                    .layoutPriority(1)
                    
                    //Настройки
                    GroupBox {
                        VStack(alignment: .leading) {
                            HStack {
                                //Period settings
                                HStack() {
                                    Text("Period")
                                        .layoutPriority(2)
                                    Spacer()
                                        .layoutPriority(1)
                                    HStack {
                                        Stepper(value: $viewModel.session.period, in: 1...300) {
                                            TextField("1...300", value: $viewModel.session.period, formatter: PeriodNumberFormatter())
                                                .onChange(of: viewModel.session.period, perform: { newValue in
                                                    viewModel.updatePeriod(newValue)
                                                    viewModel.cacalculate(for: .shots)
                                                })
                                                .textFieldStyle(.roundedBorder)
                                                .frame(maxWidth: 80)
                                        }
                                        Text("seconds")
                                    }
                                    .layoutPriority(3)
                                }
                            }
                        }
                        .padding(.all, 8.0)
                    } label: {
                        Text("Grab")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .disabled(viewModel.isGrabing)
                    .padding([.leading, .bottom, .trailing])
                    
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
                                    .onChange(of: viewModel.grabingID) { grabed in
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
                                        viewModel.selection = viewModel.grabingID
                                    }
                                    showStripSheet.toggle()
                                    print("view strip image action")
                                } label: {
                                    Image(systemName: "barcode.viewfinder")
                                }
                                .sheet(isPresented: $showStripSheet) {
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
                                Button(action) {
                                    switch viewModel.isGrabing {
                                    case true:
                                        viewModel.pause()
                                    case false:
                                        viewModel.start()
                                    }
                                }
                                .onReceive(viewModel.$isGrabing, perform: { isGrabing in
                                    let title = NSLocalizedString(isGrabing ? "Pause" : "Start", comment: "button")
                                    action = title
                                })
                                .disabled(viewModel.session.videos.isEmpty)
                                
                                Button("Cancel") {
                                    print("Cancel")
                                    viewModel.cancel()
                                }
                                .disabled(!viewModel.isGrabing)
                            }
                        }
                    }
                    .padding([.leading, .bottom, .trailing])
                }
                .disabled(isLoading)
                
                LoaderView()
                    .hidden(!isLoading)
                    .onChange(of: viewModel.isLoading) { newValue in
                        isLoading = newValue
                    }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

struct GrabView_Previews: PreviewProvider {
    static var previews: some View {
        GrabView()
        .previewLayout(.fixed(width: 600, height: 400))
    }
}
