//
//  GrabDropDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 03.12.2023.
//

import Foundation

protocol GrabModelDropHandlerOutput: AnyObject {
    var error: GrabError? { get set }
    var showAlert: Bool { get set }
    var isAnimate: Bool { get set }
    var showDropZone: Bool { get set }
}

class GrabDropHandler: DropErrorHandler, DropAnimator {
    weak var viewModel: GrabModelDropHandlerOutput?
    
    func presentError(error: DropError) {
        DispatchQueue.main.async {
            self.viewModel?.error = GrabError.map(errorDescription: error.localizedDescription, recoverySuggestion: error.recoverySuggestion)
            self.viewModel?.showAlert = true
        }
    }
    
    func animate(is animate: Bool) {
        guard viewModel?.isAnimate != animate else { return }
        DispatchQueue.main.async {
            self.viewModel?.showDropZone = animate
            self.viewModel?.isAnimate = animate
        }
    }
}
