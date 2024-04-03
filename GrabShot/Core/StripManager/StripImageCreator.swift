//
//  StripCreator.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 03.12.2023.
//

import SwiftUI

protocol StripImageCreator: AnyObject {
    func create(to url: URL, with colors: [Color], size: CGSize, stripMode: StripMode, format: FileService.Format) throws
    func render(size: CGSize, colors: [Color], stripMode: StripMode) throws -> CGImage
    func write(url: URL, cgImage: CGImage, format: FileService.Format) throws
}
