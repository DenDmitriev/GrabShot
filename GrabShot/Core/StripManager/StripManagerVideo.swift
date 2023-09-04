//
//  StripManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation
import CoreImage
import SwiftUI

class StripManagerVideo {
    
    var videos = [Video]()
    
    private var stripColorCount: Int
    
    init(stripColorCount: Int) {
        self.stripColorCount = stripColorCount
    }
    
    func appendAverageColors(for video: Video, from shotURL: URL?) {
        guard
            let imageURL = shotURL,
            let ciImage = CIImage(contentsOf: imageURL),
            let cgImage = convertCIImageToCGImage(inputImage: ciImage)
        else { return }
        do {
            let cgColors = try ColorsExtractorService.extract(from: cgImage, method: .averageAreaColor, count: stripColorCount)
            let colors = cgColors.map({ Color(cgColor: $0) })
            
            if video.colors == nil {
                video.colors = []
            }
            
            video.colors?.append(contentsOf: colors)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
}
