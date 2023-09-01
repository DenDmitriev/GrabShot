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
    
    private var colorsExtractorService: ColorsExtractorService
    private var stripColorCount: Int
    
    init(stripColorCount: Int) {
        self.stripColorCount = stripColorCount
        colorsExtractorService = ColorsExtractorService()
    }
    
    func appendAverageColors(for video: Video, from shotURL: URL?) {
        guard
            let imageURL = shotURL,
            let ciImage = CIImage(contentsOf: imageURL),
            let cgImage = convertCIImageToCGImage(inputImage: ciImage),
            let cgColors = colorsExtractorService.extract(from: cgImage, mood: .average, count: stripColorCount)
        else { return }
        let colors = cgColors.map({ Color(cgColor: $0) })
        
        if video.colors == nil {
            video.colors = []
        }
        
        video.colors?.append(contentsOf: colors)
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
}
