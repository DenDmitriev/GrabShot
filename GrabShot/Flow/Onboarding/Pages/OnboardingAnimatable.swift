//
//  OnboardingAnimatable.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.01.2024.
//

import SwiftUI
import Combine

protocol OnboardingAnimatable {
    var timer: Publishers.Autoconnect<Timer.TimerPublisher> { get set }
    var showers: [Binding<Bool>] { get set }
    
    func timerAnimationReceiver(showers: [Binding<Bool>], timer: Publishers.Autoconnect<Timer.TimerPublisher>)
}

extension OnboardingAnimatable {
    func timerAnimationReceiver(showers: [Binding<Bool>], timer: Publishers.Autoconnect<Timer.TimerPublisher>) {
        if let index = showers.firstIndex(where: { $0.wrappedValue == false }) {
            showers[index].wrappedValue = true
        } else {
            timer.upstream.connect().cancel()
        }
    }
}
