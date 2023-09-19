//
//  URLFormatter.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.09.2023.
//

import Foundation

class URLFormatter {
    static func getFormattedLinkLabel(url: URL?, placeholder: String = "URL empty") -> String {
        guard let url = url else { return placeholder }
        var label: String = ""
        let countComponents = url.pathComponents.count

        let firstPathComponent = url.pathComponents.first ?? ""
        label.append(firstPathComponent)

        if countComponents >= 3 {
            let secondIndex = url.pathComponents.index(after: .zero)
            let secondPathComponent = url.pathComponents[secondIndex] + "/"
            label.append(secondPathComponent)
            label.append(".../")
            
            let beforeLastIndex = url.pathComponents.index(before: countComponents - 1)
            let beforeLastPathComponent  = url.pathComponents[beforeLastIndex] + "/"
            label.append(beforeLastPathComponent)
        } else {
            label.append(".../")
        }

        let lastIndex = url.pathComponents.index(before: countComponents)
        let lastPathComponent = url.pathComponents[lastIndex] + "/"
        label.append(lastPathComponent)
        
        return label
    }
}
