//
//  ImageHandler.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI

protocol ImageHandler: AnyObject {
    func addImage(nsImage: NSImage, url: URL)
}
