//
//  GrabProgressView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.08.2023.
//

import SwiftUI
import Combine

struct GrabProgressView: View {
    
    @EnvironmentObject var progress: Progress
    @Binding var state: GrabState
    @Binding var duration: TimeInterval
    @State private var current: Int = .zero
    @State private var total: Int = .zero
    
    var body: some View {
        ProgressView(
            value: Double(current),
            total: Double(total)
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
        .onReceive(progress.$total) { total in
            self.total = total
        }
        .onReceive(progress.$current) { current in
            self.current = current
        }
    }
}

struct GrabProgressView_Previews: PreviewProvider {
    static var previews: some View {
        GrabProgressView(
            state: Binding<GrabState>.constant(GrabState.ready),
            duration: Binding<TimeInterval>.constant(.zero)
        )
        .environmentObject(Progress(total: .zero))
    }
}
