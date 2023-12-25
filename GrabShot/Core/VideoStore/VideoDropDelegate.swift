//
//  VideoDropDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.11.2022.
//

import SwiftUI

class VideoDropDelegate: DropDelegate {
    var store: VideoStore
    
    weak var errorHandler: DropErrorHandler?
    weak var dropAnimator: DropAnimator?
    
    init(store: VideoStore, errorHandler: DropErrorHandler? = nil, dropAnimator: DropAnimator? = nil) {
        self.store = store
        self.errorHandler = errorHandler
        self.dropAnimator = dropAnimator
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        print(#function)
        //here need add check extension files
        return true
    }
    
    func dropEntered(info: DropInfo) {
        print(#function)
        dropAnimator?.animate(is: true)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print(#function)
        info.itemProviders(for: ["public.file-url"]).forEach { [weak self] provider in
            provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
                guard
                    let self = self,
                    let data = data,
                    let url = URL(dataRepresentation: data, relativeTo: nil)
                else {
                    if let error = error {
                        let dropError = DropError.map(error: error)
                        self?.errorHandler?.presentError(error: dropError)
                    }
                    return
                }
                
                let result = FileService.shared.isTypeVideoOk(url)
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        let video = Video(url: url, store: self.store)
                        if !self.store.videos.contains(where: { $0.url == video.url }) {
                            self.store.addVideo(video: video)
                        }
                    }
                case .failure(let failure):
                    self.errorHandler?.presentError(error: failure)
                    return
                }
            }
        }
        return true
    }
    
    func dropExited(info: DropInfo) {
        print(#function)
        dropAnimator?.animate(is: false)
    }
    
}
