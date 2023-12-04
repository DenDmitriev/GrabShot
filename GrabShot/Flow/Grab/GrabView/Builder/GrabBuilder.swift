//
//  GrabBuilder.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 03.12.2023.
//

import Foundation

class GrabBuilder {
    static func build(store: VideoStore, score: ScoreController) -> GrabModel {
        let grabDropHandler = GrabDropHandler()
        let dropDelegate = VideoDropDelegate(store: store)
        let stripCreator = GrabStripCreator()
        let grabGrabManagerDelegate = GrabGrabManagerDelegate()
        grabGrabManagerDelegate.scoreController = score
        let grabManager = GrabManager(videoStore: store, period: store.period, stripColorCount: UserDefaultsService.default.stripCount)
        grabManager.delegate = grabGrabManagerDelegate
        
        let grabModel = GrabModel(
            videoStore: store,
            grabDropHandler: grabDropHandler,
            dropDelegate: dropDelegate, 
            stripCreator: stripCreator,
            grabManagerDelegate: grabGrabManagerDelegate,
            grabManager: grabManager
        )
        
        grabDropHandler.viewModel = grabModel
        dropDelegate.errorHandler = grabDropHandler
        dropDelegate.dropAnimator = grabDropHandler
        grabGrabManagerDelegate.grabModel = grabModel
        
        return grabModel
    }
}
