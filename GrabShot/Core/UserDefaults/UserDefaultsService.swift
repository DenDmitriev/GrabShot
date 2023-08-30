//
//  UserDefaultsService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import Foundation

class UserDefaultsService {
    
    let defaults: UserDefaults
    
    init() {
        self.defaults = UserDefaults.standard
    }
    
    struct Keys {
        static let period = "com.grabshot.period"
        static let quality = "com.grabshot.quality"
        static let openDirToggle = "com.grabshot.openDirToggle"
        static let stripCount = "com.grabshot.stripCount"
        static let stripHeight = "com.grabshot.stripHeight"
        static let stripWidth = "com.grabshot.stripWidth"
        static let createStrip = "com.grabshot.createStrip"
        static let grabCount = "com.grabshot.count"
        static let firstInitDate = "com.grabshot.firstInitDate"
        static let createFolder = "com.grabshot.createFolder"
        static let stripImageHeight = "com.grabshot.stripImageHeight"
        static let colorImageCount = "com.grabshot.colorImageCount"
    }
    
    func savePeriod(_ period: Int) {
        defaults.set(period, forKey: Keys.period)
    }
    
    func saveStripCount(_ count: Int) {
        defaults.set(count, forKey: Keys.stripCount)
    }
    
    func saveGrabCount(_ count: Int) {
        defaults.set(count, forKey: Keys.grabCount)
    }
    
    func saveFirstInitDate() {
        if (defaults.object(forKey: Keys.firstInitDate) as? Date) == nil {
            defaults.set(Date.now, forKey: Keys.firstInitDate)
        }
    }
    
    func getPeriod() -> Int {
        if defaults.integer(forKey: Keys.period) == 0 {
            defaults.set(30, forKey: Keys.period)
        }
        return defaults.integer(forKey: Keys.period)
    }
    
    func getGrabCount() -> Int {
        return defaults.integer(forKey: Keys.grabCount)
    }
    
    func getFirstInitDate() -> Date? {
        return defaults.object(forKey: Keys.firstInitDate) as? Date
    }
    
    func getColorImageCount() -> Int {
        return defaults.integer(forKey: Keys.colorImageCount)
    }
}
