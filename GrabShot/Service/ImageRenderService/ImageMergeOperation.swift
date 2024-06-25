//
//  ImageMergeOperation.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 31.08.2023.
//

import SwiftUI
import DominantColors

class ImageMergeOperation: AsyncOperation {
    let colors: [Color]
    let cgImage: CGImage
    let stripHeight: CGFloat
    let colorsCount: Int
    let colorMood: ColorMood
    var result: Result<Data, Error>?
    var colorsExtractorService: ColorsExtractorService?
    let format: FileService.Format
    let compressionFactor: Float
    let border: Int?
    let borderColor: CGColor?
    
    init(colors: [Color], cgImage: CGImage, stripHeight: CGFloat, colorsCount: Int, colorMood: ColorMood, format: FileService.Format, compressionFactor: Float, border: Int?, borderColor: CGColor?) {
        self.colors = colors
        self.cgImage = cgImage
        self.stripHeight = stripHeight
        self.colorsCount = colorsCount
        self.colorMood = colorMood
        self.format = format
        self.compressionFactor = compressionFactor
        self.border = border
        self.borderColor = borderColor
    }
    
    override func main() {
        Task {
            do {
                // Создание штрих-кода
                let stripCGImage = try await createStripImage(
                    size: CGSize(width: CGFloat(cgImage.width), height: stripHeight),
                    colors: colors,
                    colorMood: colorMood,
                    border: border,
                    borderColor: borderColor
                )
                
                // Соединение изображения с цветовым штрих-кодом
                let jpegData = try merge(image: cgImage, with: stripCGImage, format: format)
                
                result = .success(jpegData)
                self.state = .finished
            } catch let error {
                result = .failure(error)
                self.state = .finished
            }
        }
    }
    
    // Создание штрих-кода с цветами из прямоугольников
    private func createStripImage(size: CGSize, colors: [Color], colorMood: ColorMood, border: Int? = nil, borderColor: CGColor? = nil) async throws -> CGImage {
        let width = Int(size.width)
        let height = Int(size.height)
        
        var mutableColors = colors
        
        // Если цветов нет, то вычислим цвета
        if colors.isEmpty {
            let image = CIImage(cgImage: cgImage)
            if colorsExtractorService == nil {
                colorsExtractorService = ColorsExtractorService()
            }
            guard
                let cgImage = image.cgImage
            else { throw ImageRenderServiceError.colorsIsEmpty }
            
            let formula = colorMood.formula
            let method = colorMood.method
            let quality = colorMood.quality
            let cgColors = try await ColorsExtractorService.extract(from: cgImage, method: method, count: colorsCount, formula: formula, quality: quality)
            let colors = cgColors.map({ Color(cgColor: $0) })
            mutableColors = colors
        }
        
        guard let context = Self.createContextRectangle(colors: mutableColors, width: width, height: height, border: border, borderColor: borderColor),
              let cgImage = context.makeImage()
        else { throw ImageRenderServiceError.stripRender }
        
        return cgImage
    }
    
    // Создание контекста и рисование цветов в нем по прямоугольникам
    static func createContextRectangle(colors: [Color], width: Int, height: Int, border: Int? = nil, borderColor: CGColor? = nil) -> CGContext? {
        var widthBorder = border ?? .zero
        // Check size border
        if widthBorder > width / 10, !(0...99 ~= widthBorder), widthBorder > width / 3 {
            widthBorder = .zero
        }
        let countSegments = colors.count
        let widthTotalBorder = widthBorder * (countSegments - 1) + 2 * widthBorder
        let widthColors = width - widthTotalBorder
        let widthSegment = widthColors / countSegments
        let remainder = widthColors % colors.count
        
        let borderColor = borderColor ?? CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1.0) // white
        let borderColorAsUInt = Self.cgColorToUInt32(borderColor)
        
        let colorsAsUInt = colors.map { cgColorToUInt32($0.cgColor ?? CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1))}
        
        // Pixel line 1D
        var pixelsOnLine: [UInt32] = []
        pixelsOnLine.reserveCapacity(width)
        
        guard
            width >= countSegments
        else { return nil }
        
        let createBorder = widthBorder > .zero
        colorsAsUInt.forEach { colorAsUInt in
            if createBorder {
                let borderPixels = Array(repeating: borderColorAsUInt, count: widthBorder)
                pixelsOnLine.append(contentsOf: borderPixels)
            }
            let colorPixels = Array(repeating: colorAsUInt, count: widthSegment)
            pixelsOnLine.append(contentsOf: colorPixels)
        }
        // Add colors if has remainder pixels 1D
        if remainder != 0,
           let lastColor = colorsAsUInt.last {
            let colorPixelsRemainder = Array(repeating: lastColor, count: remainder)
            pixelsOnLine.append(contentsOf: colorPixelsRemainder)
        }
        // Close line 1D with border
        if createBorder {
            let borderPixels = Array(repeating: borderColorAsUInt, count: widthBorder)
            pixelsOnLine.append(contentsOf: borderPixels)
        }
        
        // Rectangle pixels 2D
        var pixels: [UInt32] = []
        pixels.reserveCapacity(width * height)
        // Add top border
        if createBorder {
            let borderLine = Array(repeating: borderColorAsUInt, count: width * Int(widthBorder))
            pixels.append(contentsOf: borderLine)
        }
        // Add colors rectangles with separator
        let heightColors = createBorder ? (height - (widthBorder * 2)) : height
        for _ in 1...heightColors {
            pixels += pixelsOnLine
        }
        // Add bottom border
        if createBorder {
            let borderLine = Array(repeating: borderColorAsUInt, count: width * Int(widthBorder))
            pixels.append(contentsOf: borderLine)
        }
        
        let mutableBufferPointer =  pixels.withUnsafeMutableBufferPointer { pixelsPtr in
            return pixelsPtr.baseAddress
        }
        
        let bytesPerRow = width * 4
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        let context = CGContext(
            data: mutableBufferPointer,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        )
        
        return context
    }
    
    private static func cgColorToUInt32(_ cgColor: CGColor) -> UInt32 {
        let red255   = UInt32(cgColor.red * 255)
        let green255 = UInt32(cgColor.green * 255)
        let blue255  = UInt32(cgColor.blue * 255)
        let alpha255 = UInt32(cgColor.alpha * 255)
        let colorAsUInt: UInt32 = (red255 << 24) | (green255 << 16) | (blue255 << 8) | (alpha255 << 0)
        return colorAsUInt
    }
    
    // Создание контекста и рисование цветов в нем по градиенту
    static func createContextGradient(colors: [Color], width: Int, height: Int) -> CGContext? {
        let colors = colors.compactMap({ $0.cgColor }).gradientColors(in: CGFloat(width))
        
        let colorsAsUInt = colors.compactMap { color -> UInt32? in
            guard let nsColor = NSColor(cgColor: color) else { return nil }
            let red   = UInt32(nsColor.redComponent * 255)
            let green = UInt32(nsColor.greenComponent * 255)
            let blue  = UInt32(nsColor.blueComponent * 255)
            let alpha = UInt32(nsColor.alphaComponent * 255)
            let colorAsUInt = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
            return colorAsUInt
        }
        
        var pixelsOnLine: [UInt32] = []
        
        colorsAsUInt.forEach { colorAsUInt in
            pixelsOnLine.append(colorAsUInt)
        }
        
        var pixels: [UInt32] = []
        
        for _ in 1...height {
            pixels += pixelsOnLine
        }
        
        let mutableBufferPointer =  pixels.withUnsafeMutableBufferPointer { pixelsPtr in
            return pixelsPtr.baseAddress
        }
        
        let bytesPerRow = width * 4
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        
        let context = CGContext(
            data: mutableBufferPointer,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        )
        
        return context
    }
    
    private func merge(image: CGImage, with strip: CGImage, format: FileService.Format) throws -> Data {
        let ciImage = CIImage(cgImage: image)
        let ciStrip = CIImage(cgImage: strip)
        
        let filter = CIFilter(name: "CIAdditionCompositing")!;
        var baseImage: CIImage? = ciImage.transformed(by: CGAffineTransform(translationX: 0, y: ciStrip.extent.height));
        filter.setDefaults();
        filter.setValue(baseImage, forKey: "inputImage");
        filter.setValue(ciStrip, forKey: "inputBackgroundImage");
        
        baseImage = filter.outputImage;
        
        guard let baseImage = baseImage else {
            throw ImageRenderServiceError.stripRender
        }
        
        let rep = NSCIImageRep(ciImage: baseImage);
        let finalResult = NSImage(size: rep.size);
        finalResult.addRepresentation(rep);
        
        guard let data = finalResult.tiffRepresentation else {
            throw ImageRenderServiceError.stripRender
        }
        
        let imageRep = NSBitmapImageRep(data: data)
        let imageData: Data?
        let properties: [NSBitmapImageRep.PropertyKey : Any] = [.compressionFactor: 1 - compressionFactor]
        switch format {
        case .png:
            imageData = imageRep?.representation(using: NSBitmapImageRep.FileType.png, properties: properties)
        case .jpeg:
            imageRep?.setCompression(.jpeg, factor: compressionFactor)
            imageData = imageRep?.representation(using: NSBitmapImageRep.FileType.jpeg, properties: properties)
        case .tiff:
            imageData = imageRep?.representation(using: NSBitmapImageRep.FileType.tiff, properties: properties)
        }
        
        if let imageData {
            return imageData
        } else {
            throw ImageRenderServiceError.stripRender
        }
    }
}
