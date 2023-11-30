//
//  ScoreTrigger.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2023.
//

import SwiftUI

class ScoreTrigger {
    enum Trigger {
        case donate(for: Kind)
        case review(for: Kind)
    }
    
    enum Kind {
        case grab(count: Int)
        case color(count: Int)
    }
    
    @AppStorage(DefaultsKeys.openAppCount)
    private var openAppCount: Int = 0
    
    static private let triggerDonateGrabStep: Int = 300
    static private let triggerGrabReviewStep: Int = 100
    
    static private let triggerDonateColorExtractStep: Int = 30
    static private let triggerColorExtractReviewStep: Int = 10
    
    static private let triggerOpenAppCount: Int = 5
    
    func isTime(for trigger: Trigger) -> Bool {
        guard openAppCount >= Self.triggerOpenAppCount else { return false }
        switch trigger {
        case .donate(let kind):
            switch kind {
            case .grab(let count):
                return count >= Self.triggerDonateGrabStep
            case .color(let count):
                return count >= Self.triggerDonateColorExtractStep
            }
        case .review(let kind):
            switch kind {
            case .grab(let count):
                return count >= Self.triggerGrabReviewStep
            case .color(let count):
                return count >= Self.triggerColorExtractReviewStep
            }
        }
    }
}
