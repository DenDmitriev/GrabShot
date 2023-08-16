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
        let minSize = CGSize(width: Grid.pt512, height: Grid.pt512)
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            VStack {
                DragAndDropIconView(color: .gray)
                    .frame(width: minSize.width / 4, height: minSize.width / 4, alignment: .center)
                Text("Drag&Drop")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.top)
            }
            .frame(width: width, height: height)
        }
        .onDrop(of: ["public.file-url"], delegate: viewModel.dropDelegate)
        .frame(minWidth: minSize.width, minHeight: minSize.height)
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
