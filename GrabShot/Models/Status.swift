//
//  Status.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.12.2022.
//

import Foundation

class Status {
    
    var state: State
    var log: String { build() }
    var additionally: String = ""
    
    init(state: State) {
        self.state = state
    }
    
    enum State: String {
        case ready = "Ready"
        case calculating = "Calculating"
        case grabing = "Grabbing"
        case pause = "Pause"
        case canceled = "Canceled"
        case complete = "Complete"
        
        func localizedString() -> String {
            return NSLocalizedString(self.rawValue, comment: "")
        }
        
        static func getTitleFor(title: State) -> String {
            return title.localizedString()
        }
    }
    
    
    
    func change(_ state: State, additionally: String? = nil) {
        self.state = state
        self.additionally = additionally ?? " "
    }
    
    private func build() -> String {
        state.localizedString() + additionally
    }
    
}
