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
        static let period = "period"
        static let quality = "quality"
        static let openDirToggle = "openDirToggle"
        static let stripCount = "stripCount"
        static let stripHeight = "stripHeight"
        static let stripWidth = "stripWidth"
        static let createStrip = "createStrip"
        static let grabCount = "com.grabshot.count"
        static let firstInitDate = "com.grabshot.firstInitDate"
    }
    
    func savePeriod(_ period: Int) {
        defaults.set(period, forKey: Keys.period)
    }
    
    func saveQuality(_ quality: Double) {
        defaults.set(quality, forKey: Keys.quality)
    }
    
    func saveOpenDirToggle(_ isOn: Bool) {
        defaults.set(isOn, forKey: Keys.openDirToggle)
    }
    
    func saveStripCount(_ count: Int) {
        defaults.set(count, forKey: Keys.stripCount)
    }
    
    func saveCreateStrip(_ isOn: Bool) {
        defaults.set(isOn, forKey: Keys.createStrip)
    }
    
    func saveStripSize(_ size: CGSize) {
        defaults.set(Int(size.width), forKey: Keys.stripWidth)
        defaults.set(Int(size.height), forKey: Keys.stripHeight)
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
    
    func getQuality() -> Double {
        if defaults.integer(forKey: Keys.quality) == 0 {
            defaults.set(70, forKey: Keys.quality)
        }
        return defaults.double(forKey: Keys.quality)
    }
    
    func getOpenDirToggle() -> Bool {
        return defaults.bool(forKey: Keys.openDirToggle)
    }
    
    func getStripCount() -> Int {
        if defaults.integer(forKey: Keys.stripCount) == 0 {
            defaults.set(1, forKey: Keys.stripCount)
        }
        return defaults.integer(forKey: Keys.stripCount)
    }
    
    func getStripSize() -> CGSize {
        if defaults.integer(forKey: Keys.stripWidth) == 0 || defaults.integer(forKey: Keys.stripHeight) == 0 {
            defaults.set(1280, forKey: Keys.stripWidth)
            defaults.set(128, forKey: Keys.stripHeight)
        }
        return CGSize(width: defaults.integer(forKey: Keys.stripWidth), height: defaults.integer(forKey: Keys.stripHeight))
    }
    
    func getCreateStrip() -> Bool {
        return defaults.bool(forKey: Keys.createStrip)
    }
    
    func getGrabCount() -> Int {
        return defaults.integer(forKey: Keys.grabCount)
    }
    
    func getFirstInitDate() -> Date? {
        return defaults.object(forKey: Keys.firstInitDate) as? Date
    }
}
