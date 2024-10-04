//
//  main.swift
//  SMBBrowser
//
//  Created by Anbalagan on 03/09/24.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
