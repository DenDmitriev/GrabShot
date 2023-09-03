//
//  class AverageColorsService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation
import CoreImage
import CoreGraphics
import Accelerate
import ColorCube
import SwiftUI

class ColorsExtractorService {
    
    func extract(from cgImage: CGImage, mood: ColorMood, count: Int) -> [CGColor]? {
        switch mood {
        case .colorful:
            return []
        case .muted:
            return []
        case .saturated:
            return []
        case .dark:
            return []
        case .average:
//            return sizeAreaColors(cgImage: cgImage, count: count)
            return averageColors(cgImage: cgImage, count: count)
        }
    }
    
    private func colorfulColors(cgImage: CGImage, count: Int) -> [CGColor]? {
        let nsImage = NSImage(cgImage: cgImage, size: .zero)
        let colorCube = ColorCube.ColorCube()
        
        
//        colorCube.extractColors(from: nsImage, flags: <#T##Flags#>, count: <#T##NSInteger#>)
    }
    
    private func sizeAreaColors(cgImage: CGImage, count: Int) -> [CGColor]? {
        guard let histogram = histogram(image: cgImage) else { return nil }
        var array = Array(zip(histogram.range.indices, histogram.range))
        array.sort { $0.1 > $1.1 }
        let arraySlice = array[0..<count]
        var cgColors = [CGColor]()
        arraySlice.forEach { coordinate, _ in
            let red = CGFloat(coordinate) / 255
            let green = CGFloat(coordinate) / 255
            let blue = CGFloat(coordinate) / 255
            cgColors.append(CGColor(red: red, green: green, blue: blue, alpha: 1))
        }
        if cgColors.count < count,
           let lastColor = cgColors.last {
            let appendedCount = count - cgColors.count
            (1...appendedCount).forEach { _ in
                cgColors.append(lastColor)
            }
        }
        return cgColors
    }
    
    /// Вектор слева на право с выборкой среднего цвета в каждом сегменте
    private func averageColors(cgImage: CGImage, count: Int) -> [CGColor]? {
        let ciImage = CIImage(cgImage: cgImage)
        let extentVectors = [Int] (0...(count-1)).map { part in
            let partWidth = ciImage.extent.size.width / CGFloat(count)
            let extentVector = CIVector(
                x: partWidth * CGFloat(part),
                y: ciImage.extent.origin.y,
                z: partWidth,
                w: ciImage.extent.size.height
            )
            return extentVector
        }
        
        let filters = extentVectors.compactMap {
            CIFilter(
                name: "CIAreaAverage",
                parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: $0]
            )
        }
        let outputImages = filters.compactMap { $0.outputImage }
        
        var bitmaps: [[UInt8]] = []
        guard let kCFNull = kCFNull else { return nil }
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        outputImages.forEach { outputImage in
            var bitmap = [UInt8](repeating: 0, count: 4)
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
            bitmaps.append(bitmap)
        }
        
        let colors = bitmaps.map { bitmap in
            let red = CGFloat(bitmap[0]) / 255
            let green = CGFloat(bitmap[1]) / 255
            let blue = CGFloat(bitmap[2]) / 255
            let alpha = CGFloat(bitmap[3]) / 255
            return CGColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return colors
    }
    
    /// Specifying histograms with vImage
    /// https://developer.apple.com/documentation/accelerate/specifying_histograms_with_vimage
    
    
    /// https://stackoverflow.com/questions/37470847/how-to-extract-dominant-color-from-ciareahistogram
    ///  Дает значения цветов в массиве оттенков от 0 до 255
    /// Где красный 255 0 0 будет как массив [0, ..., 1 ],  128 0 0 [0,..., 1, ..., 0]
    private func histogram(image: CGImage) -> Histogram? {
        var format = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(
                rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            renderingIntent: .defaultIntent
        )
        var histogramBinRed = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinGreen = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinBlue = [vImagePixelCount](repeating: 0, count: 256)
        var histogramBinAlpha = [vImagePixelCount](repeating: 0, count: 256)
        
        guard
            let format = format,
            var histogramSourceBuffer = try? vImage_Buffer(cgImage: image, format: format)
        else { return nil }

        defer {
            histogramSourceBuffer.free()
        }
        
        histogramBinRed.withUnsafeMutableBufferPointer { redPtr in
            histogramBinGreen.withUnsafeMutableBufferPointer { greenPtr in
                histogramBinBlue.withUnsafeMutableBufferPointer { bluePtr in
                    histogramBinAlpha.withUnsafeMutableBufferPointer { alphaPtr in
                        
                        var histogramBins = [redPtr.baseAddress, greenPtr.baseAddress,
                                             bluePtr.baseAddress, alphaPtr.baseAddress]
                        
                        histogramBins.withUnsafeMutableBufferPointer { histogramBinsPtr in
                            let error = vImageHistogramCalculation_ARGB8888(&histogramSourceBuffer,
                                                                            histogramBinsPtr.baseAddress!,
                                                                            vImage_Flags(kvImageNoFlags))
                            
                            guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }
                    }
                }
            }
        }
        
//        print("red", histogramBinRed)
//        print("green", histogramBinGreen)
//        print("blue", histogramBinBlue)
//        print("alpha", histogramBinAlpha)
//        print("total", histogramBinTotal)
        
        return Histogram(red: histogramBinRed, green: histogramBinGreen, blue: histogramBinBlue, alpha: histogramBinAlpha)
    }
    
    /// Histogram image
    /// https://knowledge.rachelbrindle.com/programming/apple/core_image.html
    private func histogram(of image: CIImage, width: CGFloat, height: CGFloat) -> CIImage {
        let ciAreaHistogram = "CIAreaHistogram"
        let histogram = image.applyingFilter(
            ciAreaHistogram,
            parameters: ["inputExtent": image.extent, "inputCount": width, "inputScale": 1]
        )
        return histogram.applyingFilter("CIHistogramDisplayFilter", parameters: ["inputHeight": height])
    }
}
