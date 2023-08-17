//
//  GrabCounter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI

class GrabCounter {
    
    static let alertTitle = NSLocalizedString(
        "Congratulations!",
        comment: "Alert title"
    )
    
    static let donateMessage = NSLocalizedString(
        "Would you like to donate to the developer for coffee ☕️ right now?",
        comment: "Alert title"
    )
    
    static let triggerStep: Int = 100
    
    static let triggerSleepSeconds: UInt32 = 2
    
    static let donateURL: URL = URL(string: "https://www.tinkoff.ru/cf/6XEnLJ43nOy")!
    
    static func alertMessage(count: Int) -> String {
        let message = NSLocalizedString(
            "You have grabbed %d shots of video.",
            comment: "Alert title"
        )
        let messageFormat = String(format: message, count)
        return messageFormat + "\n" + "\n" + donateMessage
    }
    
    static func trigger(counter: Int) -> Bool {
        let userDefaultsService = UserDefaultsService()
        
        let latestCounter = userDefaultsService.getGrabCount()
        let deltaCount = counter - latestCounter
        
        let result: Bool
        
        if deltaCount >= triggerStep {
            result = true
        } else {
            result = false
        }
        
        return result
    }
}
