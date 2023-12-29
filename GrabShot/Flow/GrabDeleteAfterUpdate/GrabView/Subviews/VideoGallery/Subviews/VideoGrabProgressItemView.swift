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
        .progressViewStyle(BagelProgressStyle())
    }
}

struct VideoGrabProgressItemView_Previews: PreviewProvider {
    static var previews: some View {
        VideoGrabProgressItemView()
            .environmentObject(Progress(total: 5))
    }
}
