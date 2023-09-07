//
//  GrabCounter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI

class GrabCounter {
    
    @AppStorage(UserDefaultsService.Keys.openAppCount)
    private var openAppCount: Int = 0
    
    static let alertTitle = NSLocalizedString(
        "Congratulations!",
        comment: "Alert title"
    )
    
    static let donateMessage = NSLocalizedString(
        "Would you like to donate to the developer for coffee ☕️ right now?",
        comment: "Alert title"
    )
    
    static let triggerStep: Int = 300
    static let triggerOpenAppCount: Int = 5
    
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
    
    func trigger(counter: Int) -> Bool {
        let userDefaultsService = UserDefaultsService()
        
        let latestCounter = userDefaultsService.getGrabCount()
        let deltaCount = counter - latestCounter
        
        let result: Bool
        
        guard
            deltaCount >= Self.triggerStep,
            openAppCount > Self.triggerOpenAppCount
        else { return false }
            
        result = true

        
        return result
    }
}
