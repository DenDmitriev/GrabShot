//
//  ColorMood.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 01.09.2023.
//

import Foundation

/// Предустановка цветового настроения для точной настройки цветоделения.
/// Каждая предустановка настроит палитру на определенный вид и настроение.
enum ColorMood {
    /// Красочное
    /// Отбор разных хветов
    case colorful
    
    /// Приглушенное
    /// Отбор по сближенности всех цветовых составляющих от 255
    case muted
    
    /// Насыщенное
    /// Отбор насыщенных цветов в области от 128 и в обе стороны с контрастной разницей состовляющих
    case saturated
    
    /// Темное
    /// Отбор  в темной гамме от 0 и вверх
    case dark
    
    /// Средний цвет
    /// Отбор средних оттенков изобрыжения слева направо
    case average
}

extension ColorMood: CustomStringConvertible {
    var description: String {
        switch self {
        case .colorful:
            return "Отбор красочных цветов"
        case .muted:
            return "Отбор по сближенности цветовых каналов"
        case .saturated:
            return "Отбор насыщенных цветов"
        case .dark:
            return "Отбор цветов в темной гамме"
        case .average:
            return "Отбор средних оттенков изобрыжения слева направо"
        }
    }
}
