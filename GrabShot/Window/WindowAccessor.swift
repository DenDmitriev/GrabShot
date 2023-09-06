//
//  WindowAccessor.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 06.09.2023.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
   @Binding
   var window: NSWindow?

   func makeNSView(context: Context) -> NSView {
      let view = NSView()
      DispatchQueue.main.async {
         self.window = view.window
      }
      return view
   }

   func updateNSView(_ nsView: NSView, context: Context) {}
}
