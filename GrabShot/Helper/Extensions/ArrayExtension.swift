//
//  ArrayExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 10.01.2024.
//

import Foundation

extension Array {
    ///  Преобразование массива в двухмерный с шагом
    func convertToTwoDimensionalArray(step: Int) -> [[Element]] {
        var target = self
        var outOfIndexArray: [Element] =  [Element]()
        
        let reminder = self.count % step
        
        if reminder > 0 && reminder <= step {
            let suffix = self.suffix(reminder)
            let list = self.prefix(self.count - reminder)
            target = Array(list)
            outOfIndexArray = Array(suffix)
        }
        
        var result: [[Element]] = stride(from: 0, to: target.count, by: step).map {
            Array(target[ $0 ..< ($0+step) ])
        }
        
        if !outOfIndexArray.isEmpty{
            result.append(outOfIndexArray)
        }
        
        return result
    }
}
