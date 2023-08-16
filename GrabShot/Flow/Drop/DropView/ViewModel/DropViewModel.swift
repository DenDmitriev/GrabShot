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
    
    var dropDelegate: VideoDropDelegate
    
    init() {
        dropDelegate = VideoDropDelegate()
        dropDelegate.errorHandler = self
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
