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
    
    init(colors: [Color], cgImage: CGImage, stripHeight: CGFloat, colorsCount: Int, colorMood: ColorMood, format: FileService.Format) {
        self.colors = colors
        self.cgImage = cgImage
        self.stripHeight = stripHeight
        self.colorsCount = colorsCount
        self.colorMood = colorMood
        self.format = format
    }
    
    override func main() {
        Task {
            do {
                // Создание штрих-кода
                let stripCGImage = try await createStripImage(
                    size: CGSize(width: CGFloat(cgImage.width), height: stripHeight),
                    colors: colors,
                    colorMood: colorMood
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
    private func createStripImage(size: CGSize, colors: [Color], colorMood: ColorMood) async throws -> CGImage {
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
            let cgColors = try await ColorsExtractorService.extract(from: cgImage, method: method, count: colorsCount, formula: formula)
            let colors = cgColors.map({ Color(cgColor: $0) })
            mutableColors = colors
        }
        
        guard let context = Self.createContextRectangle(colors: mutableColors, width: width, height: height),
              let cgImage = context.makeImage()
        else { throw ImageRenderServiceError.stripRender }
        
        return cgImage
    }
    
    // Создание контекста и рисование цветов в нем по прямоугольникам
    static func createContextRectangle(colors: [Color], width: Int, height: Int) -> CGContext? {
        
        let countSegments = colors.count
        let widthSegment = width / countSegments
        let remainder = width % colors.count
        
        let colorsAsUInt = colors.map { color -> UInt32 in
            let nsColor = NSColor(color)
            let red   = UInt32(nsColor.redComponent * 255)
            let green = UInt32(nsColor.greenComponent * 255)
            let blue  = UInt32(nsColor.blueComponent * 255)
            let alpha = UInt32(nsColor.alphaComponent * 255)
            let colorAsUInt = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
            return colorAsUInt
        }
        
        // Линия пикселей 1D
        var pixelsOnLine: [UInt32] = []
        
        guard
            width >= countSegments
        else { return nil }
        
        colorsAsUInt.forEach { colorAsUInt in
            for _ in Array(1...widthSegment) {
                pixelsOnLine.append(colorAsUInt)
            }
        }
        if remainder != 0,
           let lastColor = colorsAsUInt.last {
            Array(1...remainder).forEach { _ in
                pixelsOnLine.append(lastColor)
            }
        }
        
        // Прямоугольник пикселей 2D
        var pixels: [UInt32] = []
        for _ in Array(1...height) {
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
        switch format {
        case .png:
            imageData = imageRep?.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
        case .jpeg:
            imageData = imageRep?.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])
        case .tiff:
            imageData = imageRep?.representation(using: NSBitmapImageRep.FileType.tiff, properties: [:])
        }
        
        if let imageData {
            return imageData
        } else {
            throw ImageRenderServiceError.stripRender
        }
    }
}
