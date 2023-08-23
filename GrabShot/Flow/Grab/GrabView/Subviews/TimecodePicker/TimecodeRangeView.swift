//
//  TimecodeRangeView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.08.2023.
//

import SwiftUI

struct TimecodeRangeView: View {
    
    @ObservedObject var fromTimecode: Timecode
    @ObservedObject var toTimecode: Timecode
    
    @Binding var selectedRange: RangeType
    @State var enableTimecodeStepper: Bool
    
    init(
        fromTimecode: Timecode,
        toTimecode: Timecode,
        selectedRange: Binding<RangeType>
    ) {
        self.fromTimecode = fromTimecode
        self.toTimecode = toTimecode
        self._selectedRange = selectedRange
        let enableStepper = selectedRange.wrappedValue == .full ? false : true
        self.enableTimecodeStepper = enableStepper
    }
    
    var body: some View {
        VStack {
            GroupBox("Custom settings grabbing for video") {
                HStack {
                    Text("Duration grabbing")
                    
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
                .disabled(!enableTimecodeStepper)
            }
            .padding()
            
            Button {
                print("Close")
            } label: {
                Text("Set")
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.return)
            .padding()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct TimecodeRangeView_Previews: PreviewProvider {
    static var previews: some View {
        TimecodeRangeView(
            fromTimecode: Timecode(timeInterval: .zero),
            toTimecode: Timecode(timeInterval: 8432),
            selectedRange: .constant(.full)
        )
    }
}
