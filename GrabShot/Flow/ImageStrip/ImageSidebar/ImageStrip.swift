//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

struct ImageStrip: Hashable {
    let nsImage: NSImage
    let url: URL
    var title: String {
        url.deletingPathExtension().lastPathComponent
    }
    var colors = [Color]()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
