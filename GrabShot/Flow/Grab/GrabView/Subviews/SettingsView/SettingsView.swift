//
//  SettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var session: Session
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    //Period settings
                    HStack() {
                        Text("Period")
                            .layoutPriority(2)
                        Spacer()
                            .layoutPriority(1)
                        HStack {
                            Stepper(value: $session.period, in: 1...300) {
                                TextField("1...300", value: $session.period, formatter: PeriodNumberFormatter())
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: 80)
                            }
                            Text("seconds")
                        }
                        .layoutPriority(3)
                    }
                }
            }
            .padding(.all, 8.0)
        } label: {
            Text("Grab")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .disabled(session.isGrabbing)
        .padding([.leading, .bottom, .trailing])
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(Session.shared)
    }
}