//
//  ContentView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var session: Session
    @ObservedObject var coordinator: CoordinatorTab
    @State private var error: GrabShotError? = nil
    @State private var showAlert = false
    
    init() {
        coordinator = CoordinatorTab()
    }
    
    var body: some View {
        Group {
            switch coordinator.selectedTab {
            case .drop:
                coordinator.dropView
                    .tag(Tab.drop)
            case .grab:
                coordinator.grabView
                    .tag(Tab.grab)
            }
        }
        .toolbar {
            ToolbarItem {
                Picker("", selection: $coordinator.selectedTab) {
                    Tab.drop.image
                        .tag(Tab.drop)
                    
                    Tab.grab.image
                        .tag(Tab.grab)
                }
                .pickerStyle(.segmented)
            }
        }
        .onChange(of: session.videos) { _ in
            coordinator.selectedTab = .grab
        }
        .alert(isPresented: $session.showAlert, error: session.error) { _ in
            Button("OK", role: .cancel) {
                print("alert dismiss")
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
        .alert(isPresented: $showAlert, error: error) { _ in
            Button("OK", role: .cancel) {
                print("alert dismiss")
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .environmentObject(session)
        .navigationTitle(coordinator.selectedTab.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Session.shared)
    }
}