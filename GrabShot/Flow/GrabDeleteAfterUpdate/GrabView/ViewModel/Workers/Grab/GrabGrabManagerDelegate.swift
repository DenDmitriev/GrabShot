//
//  GrabManager.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 03.12.2023.
//

import Foundation

protocol GrabModelGrabOutput: AnyObject {
    func didStartedGrab(video: Video)
    func didUpdatedProgress(video: Video, by url: URL)
    func didCompleted(for video: Video)
    func didCompletedAll()
    func hasError(_ error: Error)
}

class GrabGrabManagerDelegate: GrabManagerDelegate {
    
    weak var grabModel: GrabModelGrabOutput?
    var scoreController: ScoreController?
    
    func hasError(_ error: Error) {
        grabModel?.hasError(error)
    }
    
    func started(video: Video) {
        grabModel?.didStartedGrab(video: video)
    }
    
    func updatedProgress(for video: Video, isCreated: Int, on timecode: Duration, by url: URL) {
        grabModel?.didUpdatedProgress(video: video, by: url)
    }
    
    func completed(for video: Video) {
        grabModel?.didCompleted(for: video)
    }
    
    func completedAll(grab count: Int) {
        scoreController?.updateGrabScore(count: count)
        grabModel?.didCompletedAll()
    }
}
