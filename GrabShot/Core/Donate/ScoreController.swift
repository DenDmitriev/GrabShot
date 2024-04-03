//
//  ScoreController.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2023.
//

import Foundation
import SwiftUI

class ScoreController: ObservableObject {
    @Published var showAlertDonate: Bool = false
    @Published var showRequestReview: Bool = false
    
    @AppStorage(DefaultsKeys.colorExtractCount)
    var colorExtractCount: Int = 0
    
    @AppStorage(DefaultsKeys.grabCount)
    var grabCount: Int = 0
    
    var isEnable: Bool = true
    
    private let caretaker: Caretaker
    
    static let alertTitle = NSLocalizedString("Congratulations!", comment: "Alert title")
    static let donateMessage = NSLocalizedString("Would you like to donate to the developer for coffee ☕️ right now?", comment: "Alert title")
    static let donateURL: URL = URL(string: "https://www.tinkoff.ru/cf/6XEnLJ43nOy")!
    static private let triggerSleepSeconds = DispatchTimeInterval.seconds(2)
    
    init(caretaker: Caretaker) {
        self.caretaker = caretaker
    }
    
    func updateGrabScore(count: Int) {
        guard isEnable else { return }
        caretaker.updateGrabScore(count: count) { update in
            let trigger = ScoreTrigger()
            let isTimeDonate = trigger.isTime(for: .donate(for: .grab(count: update.delta)))
            if isTimeDonate {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSleepSeconds) { [weak self] in
                    self?.showAlertDonate = true
                }
            }
            
            let isTimeReview = trigger.isTime(for: .review(for: .grab(count: update.delta)))
            if isTimeReview {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSleepSeconds) { [weak self] in
                    self?.showRequestReview = true
                }
            }
        }
    }
    
    func updateColorScore(count: Int) {
        caretaker.updateColorScore(count: count) { update in
            let trigger = ScoreTrigger()
            let isTimeDonate = trigger.isTime(for: .donate(for: .color(count: update.delta)))
            if isTimeDonate {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSleepSeconds) { [weak self] in
                    self?.showAlertDonate = true
                }
            }
            
            let isTimeReview = trigger.isTime(for: .review(for: .color(count: update.delta)))
            if isTimeReview {
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.triggerSleepSeconds) { [weak self] in
                    self?.showRequestReview = true
                }
            }
        }
    }
    
    static func alertMessage(count: Int) -> String {
        let message = NSLocalizedString(
            "You have grabbed %d shots of video.",
            comment: "Alert title"
        )
        let messageFormat = String(format: message, count)
        return messageFormat + "\n" + "\n" + donateMessage
    }
}
