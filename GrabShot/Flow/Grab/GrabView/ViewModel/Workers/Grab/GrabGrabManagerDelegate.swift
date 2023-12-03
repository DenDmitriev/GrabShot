//
//  GrabManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 03.12.2023.
//

import Foundation

protocol GrabModelGrabOutput: AnyObject {
    var videoStore: VideoStore { get }
    var grabbingID: Video.ID? { get set }
    var grabState: GrabState { get set }
    var progress: Progress { get set }
    var stripManager: StripManagerVideo? { get set }
    var scoreController: ScoreController { get }
    var error: GrabError? { get set }
    var showAlert: Bool { get set }
    
    func createStripImage(for video: Video)
    func buildLog(video: Video?) -> String
    func hasError(_ error: Error)
}

class GrabGrabManagerDelegate: GrabManagerDelegate {
    
    weak var grabModel: GrabModelGrabOutput?
    
    func hasError(_ error: Error) {
        grabModel?.hasError(error)
    }
    
    func started(video: Video) {
        DispatchQueue.main.async {
            self.grabModel?.grabbingID = video.id
            self.grabModel?.videoStore.isGrabbing = true
            self.grabModel?.grabState = .grabbing(log: self.grabModel?.buildLog(video: video) ?? "")
        }
    }
    
    func progress(for video: Video, isCreated: Int, on timecode: TimeInterval, by url: URL) {
        DispatchQueue.main.async {
            switch self.grabModel?.grabState {
            case .canceled:
                video.progress.current = .zero
            case .grabbing, .pause:
                self.grabModel?.progress.current += 1
                
                Task {
                    await self.grabModel?.stripManager?.appendAverageColors(for: video, from: url)
                }
                
                let log = self.grabModel?.buildLog(video: video)
                if self.grabModel?.grabState == .pause() {
                    self.grabModel?.grabState = .pause(log: log)
                } else {
                    self.grabModel?.grabState = .grabbing(log: log ?? "")
                }
            default:
                return
            }
        }
    }
    
    func completed(for video: Video) {
        if UserDefaultsService.default.openDirToggle {
            // TODO: Extract to router method
            if let exportDirectory = video.exportDirectory {
                FileService.openDirectory(by: exportDirectory)
            }
            video.exportDirectory?.stopAccessingSecurityScopedResource()
        }
        
        DispatchQueue.main.async {
            if video.progress.current == video.progress.total {
                video.isEnable = false
            }
        }
        
        grabModel?.createStripImage(for: video)
    }
    
    func completedAll(grab count: Int) {
        grabModel?.scoreController.updateGrabScore(count: count)
        DispatchQueue.main.async {
            self.grabModel?.videoStore.updateIsGrabEnable()
            self.grabModel?.grabState = .complete(shots: self.grabModel?.progress.total ?? 0)
            self.grabModel?.videoStore.isGrabbing = false
            self.grabModel?.stripManager = nil
        }
    }
}
