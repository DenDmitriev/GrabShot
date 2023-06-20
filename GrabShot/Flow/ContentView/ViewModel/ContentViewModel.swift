//
//  ContentViewModel.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 14.12.2022.
//

import Foundation

class ContentViewModel: ObservableObject {
    
    var dropView: DropView
    var grabView: GrabView
    
    init() {
        self.dropView = DropView()
        self.grabView = GrabView()
    }
}
