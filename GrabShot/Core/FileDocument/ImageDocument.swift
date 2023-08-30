//
//  ImageDocument.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImageDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.image]
    
    var data: Data?
    
    init() {
        let mockData = "Mock".data(using: .utf8)
        self.data = mockData
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.data = data
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        if let data = data {
            return FileWrapper(regularFileWithContents: data)
        } else {
            throw ImageDocumentError.data
        }
    }
}

enum ImageDocumentError: Error {
    case data
}
