//
//  VideosModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.08.2023.
//

import SwiftUI

class VideosModel: ObservableObject {
    @Published var onChangeOutputLink: Bool = false
    @Published var showAlert: Bool = false
    @Published var error: GrabError?
    @Published var grabModel: GrabModel
    @Published var showIntervalSettings = false
    @Published var showFileExporter = false
    
    @AppStorage(UserDefaultsService.Keys.createFolder)
    private var createFolder = true
    
    init(grabModel: GrabModel) {
        self.grabModel = grabModel
    }
    
    func shot(for video: Video) {
        video.updateShots()
    }
    
    func outputDidTap(on video: Video) {
        if let exportDirectory = video.exportDirectory {
            openFolder(by: exportDirectory)
        }
    }
    
    func isDisabled(by state: GrabState) -> Bool {
        switch state {
        case .ready, .canceled, .complete:
            return false
        case .calculating, .grabbing, .pause:
            return true
        }
    }
    
    func hasExportDirectory(with result: Result<URL, Error>, for video: Video) {
        switch result {
        case .success(let directory):
            if let oldExportDirectory = video.exportDirectory {
                oldExportDirectory.stopAccessingSecurityScopedResource()
            }
            
            let gotAccess = directory.startAccessingSecurityScopedResource()
            if !gotAccess { return }
            
            video.exportDirectory = directory
            grabModel.toggleGrabButton()
        case .failure(let failure):
            self.error(failure)
        }
    }
    
    func didVideoEnable() {
        grabModel.toggleGrabButton()
    }
    
    func openFolder(by path: URL) {
        FileService.openFile(for: path)
    }
    
    func getFormattedLinkLabel(url: URL?) -> String {
        URLFormatter.getFormattedLinkLabel(url: url, placeholder: "Export url empty")
    }
    
    private func error(_ error: Error) {
        DispatchQueue.main.async {
            if let localizedError = error as? LocalizedError {
                self.error = GrabError.map(
                    errorDescription: localizedError.localizedDescription,
                    recoverySuggestion: localizedError.recoverySuggestion
                )
            } else {
                self.error = GrabError.unknown
            }
            self.showAlert = true
        }
    }
}
