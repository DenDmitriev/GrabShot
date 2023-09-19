//
//  GrabCounter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI

class Counter {
    
    enum Trigger {
        case donate, review
    }
    
    @AppStorage(DefaultsKeys.openAppCount)
    private var openAppCount: Int = 0
    
    static let alertTitle = NSLocalizedString(
        "Congratulations!",
        comment: "Alert title"
    )
    
    static let donateMessage = NSLocalizedString(
        "Would you like to donate to the developer for coffee ☕️ right now?",
        comment: "Alert title"
    )
    
    static let triggerDonateGrabStep: Int = 300
    static let triggerGrabReview: Int = 100
    static let triggerDonateColorExtractStep: Int = 30
    static let triggerColorExtractReview: Int = 10
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
    
    func triggerGrab(for trigger: Trigger, counter: Int) -> Bool {
        let userDefaultsService = UserDefaultsService()
        let latestCounter = userDefaultsService.getGrabCount()
        
        let result: Bool
        
        switch trigger {
        case .donate:
            let deltaCount = counter - latestCounter
            guard
                deltaCount >= Self.triggerDonateGrabStep,
                openAppCount > Self.triggerOpenAppCount
            else { return false }
                
            result = true
        case .review:
            let totalCount = latestCounter + counter
            guard
                totalCount >= Self.triggerGrabReview,
                openAppCount > Self.triggerOpenAppCount
            else { return false }
                
            result = true
        }
        return result
    }
    
    func triggerColorExtract(for trigger: Trigger, counter: Int) -> Bool {
        let userDefaultsService = UserDefaultsService()
        let latestCounter = userDefaultsService.colorExtractCount
        
        let result: Bool
        
        switch trigger {
        case .donate:
            let deltaCount = counter - latestCounter
            guard
                deltaCount >= Self.triggerDonateColorExtractStep,
                openAppCount > Self.triggerOpenAppCount
            else { return false }
                
            result = true
        case .review:
            let totalCount = latestCounter + counter
            guard
                totalCount >= Self.triggerColorExtractReview,
                openAppCount > Self.triggerOpenAppCount
            else { return false }
                
            result = true
        }
        return result
    }
}
