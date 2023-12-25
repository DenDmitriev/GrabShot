//
//  StripManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 15.08.2023.
//

import Foundation
import CoreImage
import SwiftUI

class StripColorManager {
    
    var videos = [Video]()
    
    private var stripColorCount: Int
    
    private var colorMood: ColorMood
    
    init(stripColorCount: Int) {
        self.stripColorCount = stripColorCount
        self.colorMood = ColorMood()
    }
    
    func appendAverageColors(for video: Video, from shotURL: URL?) async {
        guard
            let imageURL = shotURL,
            let ciImage = CIImage(contentsOf: imageURL),
            let cgImage = convertCIImageToCGImage(inputImage: ciImage)
        else { return }
        do {
            let cgColors = try await ColorsExtractorService.extract(
                from: cgImage,
                method: colorMood.method,
                count: stripColorCount,
                formula: colorMood.formula,
                flags: colorMood.flags
            )
            let colors = cgColors.map({ Color(cgColor: $0) })
            
            if await video.colors == nil {
                DispatchQueue.main.async {
                    video.colors = []
                }
            }
            DispatchQueue.main.async {
                video.colors?.append(contentsOf: colors)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
}
