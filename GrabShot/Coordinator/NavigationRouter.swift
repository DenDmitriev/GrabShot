//
//  NavigationRouter.swift
//  HotelBooking
//
//  Created by Denis Dmitriev on 19.12.2023.
//

import SwiftUI

protocol NavigationRouter: Hashable, Identifiable, Equatable {
    associatedtype Content: View
    associatedtype C: NavigationCoordinator
    
    var title: String { get }
    
    @ViewBuilder func view(coordinator: C) -> Content
}
