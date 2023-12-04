//
//  GrabStripCreator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 03.12.2023.
//

import SwiftUI

class GrabStripCreator: StripCreator {
    func create(to url: URL, with colors: [Color], size: CGSize, stripMode: StripMode) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let cgImage = try? self?.render(size: size, colors: colors, stripMode: stripMode)
            if let cgImage {
                try? self?.write(url: url, cgImage: cgImage)
            }
        }
    }
    
    internal func render(size: CGSize, colors: [Color], stripMode: StripMode) throws -> CGImage {
        let context: CGContext?
        
        var width = Int(size.width)
        let height = Int(size.height)
        
        // Увеличиваем длину до количества цветов, если их больше чем пикселей нужного изображения
        if width < colors.count {
            width = colors.count
        }
        
        switch stripMode {
        case .strip:
            // Рассчитываем длину одной цветовой полосы
            let segmentWith = width / colors.count
            // Рассчитываем хвост пикселей при не ровном делении и уменьшаем длину для одинаковой длины всех полос
            let tailStrip = width % colors.count
            if tailStrip > segmentWith {
                width -= tailStrip
            }
            context = ImageMergeOperation.createContextRectangle(colors: colors, width: width, height: height)
        case .gradient:
            context = ImageMergeOperation.createContextGradient(colors: colors, width: width, height: height)
        }
        
        guard
            let context,
            let cgImage = context.makeImage()
        else {
            throw ImageRenderServiceError.stripRender
        }
        
        return cgImage
    }
    
    internal func write(url: URL, cgImage: CGImage) throws {
        try FileService.shared.writeImage(cgImage: cgImage, to: url, format: .png)
    }
}
