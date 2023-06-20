//
//  DropView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.11.2022.
//

import SwiftUI

//protocol DragViewDelegate {
//    func dragView(didDragFileWith fileURL: URL)
//}

struct DropView: View {
    
    @State private var dragOver: Bool
    
    init() {
        self.dragOver = false
    }
    
    var body: some View {
        
        //fix minSize for great view for UI
        let minSize = CGSize(width: 512, height: 512)
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            VStack {
                DragAndDropIconView(color: .gray)
                    .frame(width: minSize.width/4, height: minSize.width/4, alignment: .center)
                Text("Drag&Drop")
                    .foregroundColor(.gray)
                    .font(.caption)
                    .padding(.top)
            }
            .frame(width: width, height: height)
        }
        .onDrop(of: ["public.file-url"], delegate: VideoDropDelegate())
        .frame(minWidth: minSize.width, minHeight: minSize.height)
    }
}

struct DropView_Previews: PreviewProvider {
    static var previews: some View {
        DropView()
    }
}
