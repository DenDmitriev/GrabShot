//
//  CGImageExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 03.12.2022.
//

import Foundation
import CoreGraphics

extension CGImage {
    
    func createCGImage(color: CGColor, size: CGSize) -> CGImage? {
        
        guard let colorUInt32 = UInt32FromCGColor(color: color) else { return nil }
        
        let width = Int(size.width)
        let height = Int(size.height)
        
        var rawData = [UInt32](repeating: colorUInt32, count: width * height)
        
        let cgImage = rawData.withUnsafeMutableBytes { (raw) -> CGImage? in
            let context = CGContext(
                data: raw.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 4 * width,
                
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
                CGImageAlphaInfo.premultipliedFirst.rawValue
            )
            return context?.makeImage()
        }
        
        return cgImage
    }
    
    private func UInt32FromCGColor(color: CGColor) -> UInt32? {
        guard
            let red = color.components?[0],
            let green = color.components?[1],
            let blue = color.components?[2],
            let alpha = color.components?[3]
        else { return nil }
        
        var value: UInt32 = 0
        value += UInt32(alpha * 255) << 24
        value += UInt32(red   * 255) << 16
        value += UInt32(green * 255) << 8
        value += UInt32(blue  * 255)
        
        return value
    }
}
