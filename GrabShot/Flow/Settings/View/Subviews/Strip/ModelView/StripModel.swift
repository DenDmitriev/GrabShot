//
//  StripModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2022.
//

import SwiftUI

class StripModel: ObservableObject {
    
    let video: Video?
    
    init(video: Video?) {
        self.video = video
    }
    
    @MainActor func saveImage(view: some View) {
        DispatchQueue.main.async {
            
            let view = view.frame(width: Session.shared.stripSize.width, height: Session.shared.stripSize.height)
            let render = ImageRenderer(content: view)
            
            guard
                let cgImage = render.cgImage,
                let video = self.video
            else { return }
            
            let name = video.title + "Strip"
            let url = video.url.deletingPathExtension().appendingPathComponent(name)
            
            do {
                try FileService.shared.writeImage(cgImage: cgImage, to: url, format: .png)
            } catch {
                print(error)
            }
        }
    }
    
    func count() -> Int {
        video?.colors?.count ?? 1
    }
}
