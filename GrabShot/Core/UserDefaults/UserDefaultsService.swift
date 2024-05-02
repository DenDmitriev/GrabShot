//
//  UserDefaultsService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import SwiftUI
import DominantColors

class UserDefaultsService {
    
    static let `default` = UserDefaultsService()
    private let userDefaults: UserDefaults
    
    // MARK: - App Settings
    @AppStorage(DefaultsKeys.showPlayback)
    var showPlayback: Bool = true
    
    @AppStorage(DefaultsKeys.showTimeline)
    var showTimeline: Bool = true
    
    // MARK: - Image Settings
    
    @AppStorage(DefaultsKeys.colorExtractMethod)
    var colorExtractMethod: ColorExtractMethod = .dominationColor
    
    @AppStorage(DefaultsKeys.colorDominantFormula)
    var colorDominantFormula: DeltaEFormula = .CIE76
    
    @AppStorage(DefaultsKeys.isExcludeBlack)
    var isExcludeBlack: Bool = false
    
    @AppStorage(DefaultsKeys.isExcludeWhite)
    var isExcludeWhite: Bool = false
    
    @AppStorage(DefaultsKeys.isExcludeGray)
    var isExcludeGray: Bool = false
    
    @AppStorage(DefaultsKeys.dominantColorsQuality)
    var dominantColorsQuality: DominantColorQuality = .fair
    
    @AppStorage(DefaultsKeys.colorExtractCount)
    var colorExtractCount: Int = 0
    
    @AppStorage(DefaultsKeys.createStripBorder)
    var createStripBorder: Bool = false
    
    @AppStorage(DefaultsKeys.stripBorderWidth)
    var stripBorderWidth: Int = 5
    
    @AppStorage(DefaultsKeys.stripBorderColor)
    var stripBorderColor: Color = .white
    
    // MARK: - Video Settings
    
    @AppStorage(DefaultsKeys.period)
    var period: Double = 5
    
    @AppStorage(DefaultsKeys.stripCount)
    var stripCount: Int = 5
    
    @AppStorage(DefaultsKeys.openDirToggle)
    var openDirToggle: Bool = true
    
    @AppStorage(DefaultsKeys.quality)
    var quality: Double = 0.7
    
    @AppStorage(DefaultsKeys.createStrip)
    var createStrip: Bool = true
    
    @AppStorage(DefaultsKeys.stripWidth)
    var stripSizeWidth: Double = 1280
    
    @AppStorage(DefaultsKeys.stripHeight)
    var stripSizeHeight: Double = 128
    
    var stripSize: CGSize {
        CGSize(width: stripSizeWidth, height: stripSizeHeight)
    }
    
    @AppStorage(DefaultsKeys.grabCount)
    var grabCount: Int = 0
    
    // MARK: - Init
    
    private init() {
        self.userDefaults = UserDefaults.standard
    }
    
    // MARK: - Methods
    
    // MARK: Save
    
    func savePeriod(_ period: Double) {
        self.period = period
    }
    
    func saveStripCount(_ count: Int) {
        self.stripCount = count
    }
    
    func saveGrabCount(_ count: Int) {
        self.grabCount = count
    }
    
    func saveFirstInitDate() {
        if (userDefaults.object(forKey: DefaultsKeys.firstInitDate) as? Date) == nil {
            userDefaults.set(Date.now, forKey: DefaultsKeys.firstInitDate)
        }
    }
    
    // MARK: Get
    
    func getFirstInitDate() -> Date? {
        return userDefaults.object(forKey: DefaultsKeys.firstInitDate) as? Date
    }
}
