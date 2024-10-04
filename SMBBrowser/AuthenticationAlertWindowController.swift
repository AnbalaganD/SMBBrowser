//
//  AuthenticationAlertWindowController.swift
//  SMBBrowser
//
//  Created by Anbalagan on 05/09/24.
//

import Cocoa

final class AuthenticationAlertWindowController: NSWindowController {
    public var service: Service!
    weak var delegate: AuthenticationDelegate?

    convenience init() {
        self.init(windowNibName: "")
    }

    override func loadWindow() {
        self.window = Window(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: 200,
                height: 250
            ),
            styleMask: [.titled]
        )
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let viewController = AuthenticationAlertViewController(service: service)
        viewController.delegate = delegate
        contentViewController = viewController
    }
}
