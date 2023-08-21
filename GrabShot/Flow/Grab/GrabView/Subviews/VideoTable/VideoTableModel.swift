//
//  VideoTableModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 09.08.2023.
//

import SwiftUI

class VideoTableModel: ObservableObject {
    
    @Binding var videos: [Video]
    @Published var onChangeOutputLink: Bool = false
    @Published var showAlert: Bool = false
    @Published var error: GrabError?
    @Published var grabModel: GrabModel
    
    init(videos: Binding<[Video]>, grabModel: GrabModel) {
        self._videos = videos
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
            // access the directory URL
            // (read templates in the directory, make a bookmark, etc.)
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
        FileService.shared.openFile(for: path)
    }
    
    func getFormattedLinkLabel(url: URL?) -> String {
        guard let url = url else { return "Export url empty" }
        var label: String = ""
        let countComponents = url.pathComponents.count

        let firstPathComponent = url.pathComponents.first ?? ""
        label.append(firstPathComponent)

        if countComponents >= 3 {
            let secondIndex = url.pathComponents.index(after: .zero)
            let secondPathComponent = url.pathComponents[secondIndex] + "/"
            label.append(secondPathComponent)
            label.append(".../")
            
            let beforeLastIndex = url.pathComponents.index(before: countComponents - 1)
            let beforeLastPathComponent  = url.pathComponents[beforeLastIndex] + "/"
            label.append(beforeLastPathComponent)
        } else {
            label.append(".../")
        }

        let lastIndex = url.pathComponents.index(before: countComponents)
        let lastPathComponent = url.pathComponents[lastIndex] + "/"
        label.append(lastPathComponent)
        
        return label
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
