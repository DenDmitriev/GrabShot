//
//  ExportTabbar.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 24.01.2024.
//

import SwiftUI

struct ExportTabbar: View {
    @Binding var tab: VideoExportTab
    var body: some View {
        HStack(spacing: AppGrid.pt8) {
            ForEach(VideoExportTab.allCases) { tab in
                ZStack {
                    RoundedRectangle(cornerRadius: AppGrid.pt8)
                        .fill(backgroundItem(tab: tab))
                    
                    tab.label
                        .foregroundStyle(isSelected(tab: tab) ? .primary : .secondary)
                        .onTapGesture {
                            self.tab = tab
                        }
                }
                .frame(width: AppGrid.pt56, height: AppGrid.pt48)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(AppGrid.pt8)
        .background(.bar)
    }
    
    private func isSelected(tab: VideoExportTab) -> Bool {
        self.tab == tab
    }
    
    private func backgroundItem(tab: VideoExportTab) -> AnyShapeStyle {
        switch isSelected(tab: tab) {
        case false:
            AnyShapeStyle(.clear)
        case true:
            AnyShapeStyle(.selection)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var tab: VideoExportTab = .grab
        
        var body: some View {
            ExportTabbar(tab: $tab)
        }
    }
    
    return  PreviewWrapper()
}
