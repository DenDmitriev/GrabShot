//
//  StripModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 04.12.2022.
//

import SwiftUI

class StripModel: ObservableObject {
    
    let video: Video?
    
    init(video: Video?) {
        self.video = video
    }
    
    func count() -> Int {
        video?.colors?.count ?? 1
    }
}
