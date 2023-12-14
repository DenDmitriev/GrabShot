//
//  CustomRangePickerView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 13.12.2023.
//

import SwiftUI

struct CustomRangePickerView: View {
    
    @Binding var selectedRange: RangeType
    @Binding var enableTimecodeStepper: Bool
    @State var fromTimecode: Timecode
    @State var toTimecode: Timecode
    
    var body: some View {
        GroupBox("Custom range settings for video grabbing") {
            HStack {
                Text("Range grabbing")
                
                Spacer()
                
                Picker("", selection: $selectedRange) {
                    ForEach(RangeType.allCases, id: \.self) { interval in
                        Text(interval.label)
                            .tag(interval)
                    }
                }
                .onChange(of: selectedRange) { type in
                    let enable = (type == .excerpt)
                    enableTimecodeStepper = enable
                }
                .pickerStyle(.menu)
                .frame(width: Grid.pt128)
            }
            .padding(.all, Grid.pt8)
            
            Divider()
                .padding(.horizontal, Grid.pt8)
            
            Group {
                HStack {
                    HStack {
                        Text("From")
                        
                        Spacer()
                        
                        TimecodeStepper(timecode: fromTimecode)
                    }
                    .padding(.all, Grid.pt8)
                    
                    HStack {
                        Text("To")
                        
                        Spacer()
                        
                        TimecodeStepper(timecode: toTimecode)
                    }
                    .padding(.all, Grid.pt8)
                }
                
            }
            .disabled(!enableTimecodeStepper)
        }
        .padding()
    }
}

#Preview {
    CustomRangePickerView(
        selectedRange: .constant(.full),
        enableTimecodeStepper: .constant(true),
        fromTimecode: Timecode(timeInterval: 1200, maxTimeInterval: 3600),
        toTimecode: Timecode(timeInterval: 2400, maxTimeInterval: 3600)
    )
}
