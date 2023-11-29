//
//  ImageStore.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 29.08.2023.
//

import SwiftUI
import Combine

class ImageStore: ObservableObject {
    static let shared = ImageStore()
    
    @Published var imageStrips: [ImageStrip] = []
    @Published var showAlertDonate: Bool = false
    @Published var showRequestReview: Bool = false
    @Published var currentColorExtractCount: Int = 0
    @AppStorage(DefaultsKeys.colorExtractCount) var colorExtractCount: Int = 0
    
    private var store = Set<AnyCancellable>()
    private var backgroundGlobalQueue = DispatchQueue.global(qos: .background)
    
    init() {
        currentColorExtractCount = colorExtractCount
        bindColorExtractCounter()
    }

    func insertImage(_ image: ImageStrip) {
        if !imageStrips.contains(where: { $0.url == image.url }) {
            imageStrips.append(image)
        }
    }
    
    func imageStrip(id: UUID?) -> ImageStrip? {
        imageStrips.first(where: { $0.id == id })
    }
    
    func insertImages(_ urls: [URL]) {
        DispatchQueue.global(qos: .utility).async {
            urls.forEach { url in
                let imageStrip = ImageStrip(url: url)
                DispatchQueue.main.async {
                    self.insertImage(imageStrip)
                }
            }
        }
    }
    
    private func bindColorExtractCounter() {
        $currentColorExtractCount
            .receive(on: backgroundGlobalQueue)
            .sink { [weak self] count in
                let counter = Counter()
                if counter.triggerColorExtract(for: .donate, counter: count) {
                    sleep(Counter.triggerSleepSeconds)
                    DispatchQueue.main.async {
                        self?.showAlertDonate = true
                    }
                }
                
                if counter.triggerColorExtract(for: .review, counter: count) {
                    sleep(Counter.triggerSleepSeconds)
                    DispatchQueue.main.async {
                        self?.showRequestReview = true
                    }
                }
            }
            .store(in: &store)
    }
    
    func updateColorExtractCounter(_ count: Int) {
        DispatchQueue.main.async {
            self.currentColorExtractCount += count
        }
    }
    
    func syncColorExtractCounter() {
        DispatchQueue.main.async {
            self.colorExtractCount = self.currentColorExtractCount
        }
    }
}
