//
//  AppDelegate.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var aboutBoxWindowController: NSWindowController?
    
    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable,/* .resizable,*/ .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = NSLocalizedString("About application GrabShot", comment: "Title")
            window.contentView = NSHostingView(rootView: AboutView())
            window.center()
            aboutBoxWindowController = NSWindowController(window: window)
        }
        
        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
    }
}
