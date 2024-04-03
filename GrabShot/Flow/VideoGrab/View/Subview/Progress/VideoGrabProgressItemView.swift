//
//  VideoGrabProgressItemView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.09.2023.
//

import SwiftUI

struct VideoGrabProgressItemView: View {
    
    @EnvironmentObject var progress: Progress
    @State var total: Int = 1
    @State var current: Int = .zero
    
    var body: some View {
        ProgressView(
            value: Double(current),
            total: Double(total)
        )
        .onReceive(progress.$total, perform: { total in
            withAnimation {
                self.total = total
            }
        })
        .onReceive(progress.$current, perform: { current in
            withAnimation {
                self.current = current
            }
        })
        .progressViewStyle(.bagel)
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            HStack(spacing: 24) {
                VideoGrabProgressItemView()
                    .environmentObject(Progress(total: 5))
                
                VideoGrabProgressItemView()
                    .environmentObject(Progress(current: 1, total: 5))
                
                VideoGrabProgressItemView()
                    .environmentObject(Progress(current: 3, total: 5))
                
                VideoGrabProgressItemView()
                    .environmentObject(Progress(current: 5, total: 5))
            }
            .background(.background)
        }
    }
    
    return VStack(spacing: 24) {
        PreviewWrapper()
            .environment(\.colorScheme, .light)
        
        PreviewWrapper()
            .environment(\.colorScheme, .dark)
    }
    .padding()
}
