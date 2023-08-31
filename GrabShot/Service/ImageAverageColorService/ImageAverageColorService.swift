//
//  ImageAverageColorService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import SwiftUI

class ImageAverageColorService {
    
    let operationQueue: OperationQueue = {
       let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .utility
        return operationQueue
    }()
    
    // MARK: - Functions
    
    func getColors(nsImage: NSImage, colorCount: Int, completion: @escaping (([Color]) -> Void)){
        let operation = ImageAverageColorOperation(nsImage: nsImage, colorCount: colorCount)
        operation.qualityOfService = .utility
        operation.completionBlock = {
            completion(operation.result)
        }
        operationQueue.addOperation(operation)
    }
    
    // MARK: - Private Functions
    
}
