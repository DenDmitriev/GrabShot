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
    @Published var currentColorExtractCounter: Int = 0
    @Published var showAlertDonate: Bool = false
    @Published var showRequestReview: Bool = false
    @AppStorage(UserDefaultsService.Keys.colorExtractCount) var colorExtractCount: Int = 0
    
    private var store = Set<AnyCancellable>()
    private var backgroundGlobalQueue = DispatchQueue.global(qos: .background)
    
    init() {
        bindColorExtractCounter()
    }

    init(imageURLs: [URL]) {
        insertImages(imageURLs)
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
                do {
                    let data = try Data(contentsOf: url)
                    guard let nsImage = NSImage(data: data) else { return }
                    let imageStrip = ImageStrip(nsImage: nsImage, url: url)
                    DispatchQueue.main.async {
                        self.insertImage(imageStrip)
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func bindColorExtractCounter() {
        $currentColorExtractCounter
            .receive(on: backgroundGlobalQueue)
            .sink { [weak self] counter in
                let grabCounter = Counter()
                if grabCounter.triggerColorExtract(for: .donate, counter: counter) {
                    sleep(Counter.triggerSleepSeconds)
                    DispatchQueue.main.async {
                        self?.showAlertDonate = true
                    }
                }
                
                if grabCounter.triggerColorExtract(for: .review, counter: counter) {
                    sleep(Counter.triggerSleepSeconds)
                    DispatchQueue.main.async {
                        self?.showRequestReview = true
                    }
                }
            }
            .store(in: &store)
    }
}
