//
//  DropViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.08.2023.
//

import Foundation

class DropViewModel: ObservableObject {
    
    @Published var error: DropError?
    @Published var showAlert: Bool = false
    @Published var isAnimate: Bool = false
    @Published var showDropZone: Bool = false
    
    var dropDelegate: VideoDropDelegate
    
    init() {
        dropDelegate = VideoDropDelegate()
        dropDelegate.errorHandler = self
        dropDelegate.dropAnimator = self
    }
}

extension DropViewModel: DropErrorHandler {
    func presentError(error: DropError) {
        DispatchQueue.main.async {
            self.error = error
            self.showAlert = true
        }
    }
}

extension DropViewModel: DropAnimator {
    func animate(is animate: Bool) {
        guard isAnimate != animate else { return }
        DispatchQueue.main.async {
            self.showDropZone = animate
            self.isAnimate = animate
        }
    }
}
