//
//  SettingsView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.08.2023.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var session: Session
    @ObservedObject var viewModel = SettingsViewModel()
    @Binding var grabState: GrabState
    
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
                                    .frame(maxWidth: Grid.pt80)
                            }
                            Text("seconds")
                        }
                        .layoutPriority(3)
                    }
                }
            }
            .padding(.all, Grid.pt8)
        } label: {
            Text("Grab")
                .font(.title3)
                .foregroundColor(.gray)
        }
        .disabled(!viewModel.isEnable(state: grabState))
        .padding([.leading, .bottom, .trailing])
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(grabState: Binding<GrabState>.constant(GrabState.calculating))
            .environmentObject(Session.shared)
    }
}
