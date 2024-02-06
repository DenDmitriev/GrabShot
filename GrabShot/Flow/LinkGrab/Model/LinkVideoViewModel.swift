//
//  LinkVideoViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.01.2024.
//

import Foundation

class LinkVideoViewModel: ObservableObject {
    weak var coordinator: LinkGrabCoordinator?
    @Published var error: GrabError?
    @Published var hasError: Bool = false
}

extension LinkVideoViewModel {
    static func build(score: ScoreController, coordinator: LinkGrabCoordinator? = nil) -> LinkVideoViewModel {
        let viewModel = LinkVideoViewModel()
        viewModel.coordinator = coordinator
        
        return viewModel
    }
}
