//
//  OnboardingPage.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

enum OnboardingPage: CaseIterable {
    case welcome
    case interface
    case importVideo
    case importImage
    
    static let fullOnboarding = OnboardingPage.allCases
}

extension OnboardingPage {
    var shouldShowNextButton: Bool {
        switch self {
        case .welcome, .interface, .importVideo:
            return true
        default:
            return false
        }
    }
}

extension OnboardingPage {
    @ViewBuilder
    func view(action: @escaping () -> Void) -> some View {
        switch self {
        case .welcome:
            WelcomePage()
        case .interface:
            InterfacePage()
        case .importVideo:
            ImportVideoPage()
        case .importImage:
            ImportImagePage()
        }
    }
}
