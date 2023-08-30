//
//  ExportDirectory.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportDirectory: FileDocument {
    static var readableContentTypes: [UTType] = [.directory]
    var title: String
    
    init(title: String) {
        self.title = title
    }

    init(configuration: ReadConfiguration) throws {
        title = ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(directoryWithFileWrappers: [:])
    }
}
