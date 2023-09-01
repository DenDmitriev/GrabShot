//
//  NSImageExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 02.12.2022.
//

import SwiftUI

extension CIImage {
//    var averageColor: Color? {
//        let extentVector = CIVector(x: self.extent.origin.x, y: self.extent.origin.y, z: self.extent.size.width, w: self.extent.size.height)
//        
//        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: extentVector]) else { return nil }
//        guard let outputImage = filter.outputImage else { return nil }
//        
//        var bitmap = [UInt8](repeating: 0, count: 4)
//        guard let kCFNull = kCFNull else { return nil }
//        let context = CIContext(options: [.workingColorSpace: kCFNull])
//        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
//        
//        //NSColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
//        //CGColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
//        let color = Color(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255)
//        
//        return color
//    }
    
    func averageColors(count: Int) -> [Color]? {
        let extentVectors = [Int] (0...(count-1)).map { part in
            let partWidth = self.extent.size.width / CGFloat(count)
            let extentVector = CIVector(x: partWidth * CGFloat(part), y: self.extent.origin.y, z: partWidth, w: self.extent.size.height)
            return extentVector
        }
        
        let filters = extentVectors.compactMap { CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: $0]) }
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
            return Color(red: red, green: green, blue: blue)
        }
        
        return colors
    }
}
