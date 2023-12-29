//
//  TimecodePickerModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 11.12.2023.
//

import Foundation

class TimecodePickerModel: ObservableObject {
    @Published var isProgress: Bool = false
    @Published var error: TimcodePickerError?
    
    private var playerObservers: [NSKeyValueObservation?] = []
    
    deinit {
        playerObservers.forEach({ $0?.invalidate() })
    }
    
    func addObserver(observer: NSKeyValueObservation?) {
        playerObservers.append(observer)
    }
    
    func cache(video: Video, completion: @escaping ((URL?) -> Void)) {
        updateProgress(true)
        DispatchQueue.global(qos: .userInitiated).async {
            VideoService.cache(for: video) { result in
                self.updateProgress(false)
                switch result {
                case .success(let success):
                    completion(success)
                case .failure(let failure):
                    if let error = failure as? LocalizedError {
                        self.hasError(error)
                        completion(nil)
                    }
                }
            }
        }
    }
    
    private func updateProgress(_ progress: Bool) {
        DispatchQueue.main.async {
            self.isProgress = progress
        }
    }
    
    private func hasError(_ error: Error) {
        DispatchQueue.main.async {
            self.error = TimcodePickerError.map(errorDescription: error.localizedDescription)
        }
    }
}
