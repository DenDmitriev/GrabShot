//
//  VideoDropDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 23.11.2022.
//

import SwiftUI

struct VideoDropDelegate: DropDelegate {
    
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
        info.itemProviders(for: ["public.file-url"]).forEach { provider in
            provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
                guard
                    let data = data,
                    let url = URL(dataRepresentation: data, relativeTo: nil),
                    FileService.shared.isTypeVideoOk(url)
                else {
                    print(error?.localizedDescription ?? "error file path")
                    return
                }
                DispatchQueue.main.async {
                    let video = Video(url: url)
                    if !Session.shared.videos.contains(where: { $0.url == video.url }) {
                        Session.shared.videos.append(video)
                    }
                }
            }
        }
        return true
    }
    
    func dropExited(info: DropInfo) {
        print(#function)
    }
    
}
