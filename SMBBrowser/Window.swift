//
//  Window.swift
//  SMBBrowser
//
//  Created by Anbalagan on 06/09/24.
//

import AppKit

class Window: NSWindow {
    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask = [.fullSizeContentView],
        backing backingStoreType: NSWindow.BackingStoreType = .buffered,
        defer flag: Bool = true
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: backingStoreType,
            defer: flag
        )
        isMovableByWindowBackground = true
        backgroundColor = NSColor.windowBackgroundColor
    }
}
