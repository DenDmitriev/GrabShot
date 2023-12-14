//
//  SettingsModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import SwiftUI

class SettingsModel: ObservableObject {
    
    private let userDefaults: UserDefaultsService = .default
    
    func updateCreateStripToggle(value: Bool) {
        UserDefaultsService.default.createStrip = value
    }
    
    func getCacheSize() -> FileSize? {
        if let sizeInBytes = FileService.getCacheSize() {
            let fileSize = FileSize(size: Double(sizeInBytes), unit: .byte)
            return fileSize
        } else {
            return nil
        }
    }
    
    func getJpegCacheSize() -> FileSize? {
        if let sizeInBytes = FileService.getJpegCacheSize() {
            let fileSize = FileSize(size: Double(sizeInBytes), unit: .byte)
            return fileSize
        } else {
            return nil
        }
    }
    
    func getVideoCacheSize() -> FileSize? {
        if let sizeInBytes = FileService.getVideoCacheSize() {
            let fileSize = FileSize(size: Double(sizeInBytes), unit: .byte)
            return fileSize
        } else {
            return nil
        }
    }
}
