//
//  VideoDropDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.11.2022.
//

import SwiftUI

class VideoDropDelegate: DropDelegate {
    
    weak var errorHandler: DropErrorHandler?
    
    init(errorHandler: DropErrorHandler? = nil) {
        self.errorHandler = errorHandler
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        print(#function)
        //here need add check extension files
        return true
    }
    
    func dropEntered(info: DropInfo) {
        print(#function)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        print(#function)
        info.itemProviders(for: ["public.file-url"]).forEach { [weak self] provider in
            provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
                guard
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
                        let video = Video(url: url)
                        if !Session.shared.videos.contains(where: { $0.url == video.url }) {
                            Session.shared.addVideo(video: video)
                        }
                    }
                case .failure(let failure):
                    self?.errorHandler?.presentError(error: failure)
                    return
                }
            }
        }
        return true
    }
    
    func dropExited(info: DropInfo) {
        print(#function)
    }
    
}
