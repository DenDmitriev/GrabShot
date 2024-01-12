//
//  SettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var period: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                //Period settings
                HStack() {
                    Text("Period")
                        .layoutPriority(2)
                    Spacer()
                        .layoutPriority(1)
                    HStack {
                        let range: ClosedRange<Double> = 1...300
                        Stepper(value: $period, in: range) {
                            TextField("1...300", value: $period, format: .ranged(range))
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: AppGrid.pt80)
                        }
                        Text("seconds")
                    }
                    .layoutPriority(3)
                }
            }
        }
        .padding(.all, AppGrid.pt8)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(period: .constant(30))
    }
}
