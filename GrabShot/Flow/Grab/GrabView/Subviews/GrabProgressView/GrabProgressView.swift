//
//  GrabProgressView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.08.2023.
//

import SwiftUI
import Combine

struct GrabProgressView: View {
    
    @Binding var progress: Progress
    @Binding var state: GrabState
    @Binding var duration: TimeInterval
    
    var body: some View {
        ProgressView(
            value: Double(progress.current),
            total: Double(progress.total)
        ) {
            HStack {
                Text(state.localizedString())
                
                Spacer()
                
                Text(DurationFormatter.stringWithUnits(duration) ?? "")
                    .foregroundColor(.gray)
            }
        } currentValueLabel: {
            HStack {
                Text(state.description)
                
                Spacer()
                
                if progress.total != .zero {
                    Text(progress.current.formatted(.number))
                    Text(NSLocalizedString("from", comment: "Progress view"))
                    Text(progress.total.formatted(.number))
                }
            }
        }
        .progressViewStyle(.linear)
    }
}

struct GrabProgressView_Previews: PreviewProvider {
    static var previews: some View {
        GrabProgressView(progress: Binding<Progress>.constant(Progress(current: .zero, total: .zero)), state: Binding<GrabState>.constant(GrabState.ready), duration: Binding<TimeInterval>.constant(.zero))
    }
}
