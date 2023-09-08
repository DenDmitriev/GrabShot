//
//  ImageStrip.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

class ImageStrip: Hashable, Identifiable, ObservableObject {
    
    let id: UUID
    let nsImage: NSImage
    let url: URL
    let ending = ".Strip"
    let imageExtension = "jpg"
    
    var title: String {
        url.deletingPathExtension().lastPathComponent
    }
    var exportTitle: String {
        title
            .appending(ending)
            .appending(".")
            .appending(imageExtension)
    }
    
    var exportURL: URL?
    
    @Published var colors = [Color]()
    @ObservedObject var colorMood: ColorMood
    
    init(nsImage: NSImage, url: URL, colors: [Color] = [Color](), exportDirectory: URL? = nil) {
        self.id = UUID()
        self.nsImage = nsImage
        self.url = url
        self.colors = colors
        self.exportURL = exportDirectory
        self.colorMood = .init()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageStrip, rhs: ImageStrip) -> Bool {
        lhs.id == rhs.id
    }
}
