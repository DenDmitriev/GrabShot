//
//  SettingsViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.08.2023.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    func isEnable(state: GrabState) -> Bool {
        switch state {
        case .ready, .canceled, .complete:
            return true
        case .calculating, .grabbing, .pause:
            return false
        }
    }
    
}
