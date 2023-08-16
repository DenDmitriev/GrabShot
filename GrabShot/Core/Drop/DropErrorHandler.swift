//
//  DropErrorHandler.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.08.2023.
//

import Foundation

protocol DropErrorHandler: AnyObject {
    func presentError(error: DropError)
}
