//
//  ImagerCreator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import Cocoa

class ImagerCreator {
    static func merge(image: CGImage, with strip: CGImage) -> Data? {
        let ciImage = CIImage(cgImage: image)
        let ciStrip = CIImage(cgImage: strip)
        
        let filter = CIFilter(name: "CIAdditionCompositing")!;
        var baseImage: CIImage? = ciImage.transformed(by: CGAffineTransform(translationX: 0, y: ciStrip.extent.height));
        filter.setDefaults();
        filter.setValue(baseImage, forKey: "inputImage");
        filter.setValue(ciStrip, forKey: "inputBackgroundImage");
        
        baseImage = filter.outputImage;
        
        guard let baseImage = baseImage else { return nil }
        
        let rep = NSCIImageRep(ciImage: baseImage);
        let finalResult = NSImage(size: rep.size);
        finalResult.addRepresentation(rep);
        
        guard let data = finalResult.tiffRepresentation else { return nil }
        
        let imageRep = NSBitmapImageRep(data: data)
        let jpegData = imageRep?.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:]);
        
        return jpegData
    }
}
