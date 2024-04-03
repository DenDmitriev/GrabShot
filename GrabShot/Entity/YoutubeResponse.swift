//
//  YoutubeResponse.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation

struct YoutubeResponse: Codable {
    let url: URL
    let title: String
    let coverURL: URL?
    let description: String?
}
