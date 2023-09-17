//
//  UserDefaultsService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 30.11.2022.
//

import SwiftUI
import DominantColors

class UserDefaultsService {
    
    let defaults: UserDefaults
    
    @AppStorage(DefaultsKeys.colorExtractMethod)
    var colorExtractMethod: ColorExtractMethod = .dominationColor
    
    @AppStorage(DefaultsKeys.colorDominantFormula)
    var colorDominantFormula: DeltaEFormula = .CIE76
    
    @AppStorage(DefaultsKeys.isExcludeBlack)
    var isExcludeBlack: Bool = false
    
    @AppStorage(DefaultsKeys.isExcludeWhite)
    var isExcludeWhite: Bool = false
    
    @AppStorage(DefaultsKeys.colorExtractCount)
    var colorExtractCount: Int = 0
    
    init() {
        self.defaults = UserDefaults.standard
    }
    
    func savePeriod(_ period: Int) {
        defaults.set(period, forKey: DefaultsKeys.period)
    }
    
    func saveStripCount(_ count: Int) {
        defaults.set(count, forKey: DefaultsKeys.stripCount)
    }
    
    func saveGrabCount(_ count: Int) {
        defaults.set(count, forKey: DefaultsKeys.grabCount)
    }
    
    func saveFirstInitDate() {
        if (defaults.object(forKey: DefaultsKeys.firstInitDate) as? Date) == nil {
            defaults.set(Date.now, forKey: DefaultsKeys.firstInitDate)
        }
    }
    
    func getPeriod() -> Int {
        if defaults.integer(forKey: DefaultsKeys.period) == 0 {
            defaults.set(30, forKey: DefaultsKeys.period)
        }
        return defaults.integer(forKey: DefaultsKeys.period)
    }
    
    func getGrabCount() -> Int {
        return defaults.integer(forKey: DefaultsKeys.grabCount)
    }
    
    func getFirstInitDate() -> Date? {
        return defaults.object(forKey: DefaultsKeys.firstInitDate) as? Date
    }
    
    func getColorImageCount() -> Int {
        return defaults.integer(forKey: DefaultsKeys.colorImageCount)
    }
}
