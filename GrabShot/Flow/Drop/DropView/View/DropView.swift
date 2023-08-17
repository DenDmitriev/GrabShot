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
        GeometryReader { geometry in
            
            VStack {
                VStack {
                    Image(systemName: "film.stack")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(maxWidth: Grid.pt64)
                    
                    Image(systemName: "arrow.down")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(maxWidth: Grid.pt32)
                        .offset(y: -Grid.pt18)
                }
                
                Text("Drag&Drop")
                    .foregroundColor(.gray)
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .padding(.top)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Grid.pt8)
                    .stroke(style: StrokeStyle(
                        lineWidth: Grid.pt2,
                        lineCap: .round,
                        dash: [Grid.pt10, Grid.pt6],
                        dashPhase: viewModel.isAnimate ? Grid.pt16 : 0)
                    )
                    .foregroundColor(.gray)
                    .frame(width: geometry.size.width - Grid.pt32, height: geometry.size.height - Grid.pt32, alignment: .center)
                    .animation(.linear(duration: 0.5).repeatForever(autoreverses: false), value: viewModel.isAnimate
                    )
                    .opacity(viewModel.showDropZone ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onDrop(of: ["public.file-url"], delegate: viewModel.dropDelegate)
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
