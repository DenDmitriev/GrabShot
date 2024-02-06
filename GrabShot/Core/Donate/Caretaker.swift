//
//  Caretaker.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2023.
//

import SwiftUI

class Caretaker: ObservableObject {
    struct Update {
        var delta: Int
        let current: Int
    }
    
    private var sceneGrabScore: Update = Update(delta: .zero, current: UserDefaultsService.default.grabCount)
    private var sceneColorScore: Update = Update(delta: .zero, current: UserDefaultsService.default.colorExtractCount)
    
    @AppStorage(DefaultsKeys.colorExtractCount)
    private var colorExtractCount: Int = 0
    
    @AppStorage(DefaultsKeys.grabCount)
    private var grabCount: Int = 0
    
    func updateGrabScore(count: Int, handler: @escaping ((Update) -> Void)) {
        sceneGrabScore.delta += count
        grabCount += count
        
        handler(sceneGrabScore)
    }
    
    func loadGrabScore() -> Int {
        return grabCount
    }
    
    func updateColorScore(count: Int, handler: @escaping ((Update) -> Void)) {
        sceneColorScore.delta += count
        colorExtractCount = +count
        
        handler(sceneColorScore)
    }
    
    func loadColorScore() -> Int {
        return colorExtractCount
    }
}
