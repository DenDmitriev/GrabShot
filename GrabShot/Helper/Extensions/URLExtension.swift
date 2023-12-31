//
//  URLExtension.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 08.09.2023.
//

import Foundation

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
