//
//  ContentView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var session: Session
    @State private var selectedTab: Int
    
    var viewModel: ContentViewModel
    
    init() {
        self.session = Session.shared
        self.selectedTab = Session.shared.selectedTab
        self.viewModel = ContentViewModel()
    }
    
    var body: some View {
        
        Group {
            switch selectedTab {
            case TabApp.dropTab.id:
                viewModel.dropView
                    .environmentObject(session)
            case TabApp.grabTab.id:
                viewModel.grabView
                    .environmentObject(session)
            default:
                Text("N/A")
            }
        }
        .toolbar {
            Picker("", selection: $selectedTab) {
                ForEach(TabApp.tabs) { tab in
                    tab.image
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedTab) { tab in
                session.selectedTab = tab
            }
            .onChange(of: session.selectedTab) { tab in
                selectedTab = tab
            }
            .onChange(of: session.videos) { _ in
                selectedTab = TabApp.grabTab.id
            }
        }
        .navigationTitle(TabApp.tabs[selectedTab].title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
