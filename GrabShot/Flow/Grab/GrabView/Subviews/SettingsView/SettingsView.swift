//
//  SettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var period: Int
    
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
                        Stepper(value: $period, in: 1...300) {
                            TextField("1...300", value: $period, format: .ranged(0...300))
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
