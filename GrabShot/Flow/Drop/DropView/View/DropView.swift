//
//  DropView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI

struct DropView: View {
    
    @ObservedObject var viewModel: DropViewModel
    @EnvironmentObject var session: Session
    @State private var dragOver: Bool
    
    init() {
        viewModel = DropViewModel()
        self.dragOver = false
    }
    
    var body: some View {
        ZStack {
            DropVideoIcon()
            
            DropZoneView(isAnimate: $viewModel.isAnimate, showDropZone: $viewModel.showDropZone)
        }
        .onDrop(of: FileService.utTypes, delegate: viewModel.dropDelegate)
        .frame(minWidth: Grid.pt512, minHeight: Grid.pt512)
        .alert(isPresented: $viewModel.showAlert, error: viewModel.error) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.recoverySuggestion ?? error.localizedDescription)
        }
    }
}

struct DropView_Previews: PreviewProvider {
    static var previews: some View {
        DropView()
            .environmentObject(Session.shared)
    }
}
