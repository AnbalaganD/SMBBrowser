//
//  SMBListViewController.swift
//  SMBBrowser
//
//  Created by Anbalagan on 03/09/24.
//

import Cocoa
import dnssd
import NetFS

final class SMBListViewController: NSViewController {
    private let smbServiceBrowser = SMBServiceBrowser()
    private var services = [Service]()
    private let lock = NSLock()
    
    private var appearenceObserver: NSKeyValueObservation?
    private var scrollView: NSScrollView!
    private var smbServiceTableView: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addNotificationObserver()
        getSMBServices()
    }
    
    private func getSMBServices() {
        Task {
            let services = self.smbServiceBrowser.getServices()
            for await service in services {
                lock.withLock {
                    if service.operation == .added {
                        self.services.append(service)
                    } else {
                        self.services.removeAll { $0.id == service.id }
                    }

                    Task { @MainActor in
                        smbServiceTableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func mountSMBShare(
        url: URL,
        username: String,
        password: String
    ) -> Bool {
        let mountOptions = NSMutableDictionary()
        
        mountOptions[kNetFSUserNameKey] = username
        mountOptions[kNetFSPasswordKey] = password
        
        var mountRef: Unmanaged<CFArray>?
        
        let status = NetFSMountURLSync(
            url as CFURL,
            nil,
            username as CFString,
            password as CFString,
            mountOptions,
            nil,
            &mountRef
        )
        
        if status == 0 {
            print("Successfully mounted \(url.absoluteString)")
            return true
        } else {
            print("Failed to mount \(url.absoluteString) with error code: \(status)")
            return false
        }
    }
}

private extension SMBListViewController {
    func setupView() {
        view.wantsLayer = true

        smbServiceTableView = NSTableView()
        smbServiceTableView.translatesAutoresizingMaskIntoConstraints = false
        let tableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("smb_service_list"))
        smbServiceTableView.addTableColumn(tableColumn)
        smbServiceTableView.intercellSpacing = .init(width: 0, height: 0)
        smbServiceTableView.backgroundColor = NSColor.clear;
        smbServiceTableView.headerView = nil
        smbServiceTableView.style = .plain
        smbServiceTableView.delegate = self
        smbServiceTableView.dataSource = self

        scrollView = NSScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = smbServiceTableView
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func addNotificationObserver() {
        appearenceObserver = NSApp.observe(
            \.effectiveAppearance,
             options: [.new, .initial]
        ) { [weak self] _, observer in
            guard let appearance = observer.newValue?.bestMatch(from: [.aqua, .darkAqua]) else {
                return
            }

            self?.appearenceDidChange(appearance)
        }
    }
    
    private func appearenceDidChange(_ appearance: NSAppearance.Name) {
        view.layer?.backgroundColor = appearance == .aqua ? NSColor.white.cgColor : NSColor.black.cgColor
    }
}

extension SMBListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return services.count
    }
    
    func tableView(
        _ tableView: NSTableView,
        viewFor tableColumn: NSTableColumn?,
        row: Int
    ) -> NSView? {
        var cell = tableView.makeView(withIdentifier: SMBTableCell.cellIdentifier, owner: self) as? SMBTableCell
        if cell == nil {
            cell = SMBTableCell()
        }
        if row >= services.count { return nil }
        let service = services[row]
        cell?.setupData(
            computerName: service.smbService.name,
            address: "smb://\(service.smbService.ipv4!)"
        )
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else {
            return
        }
        
        let selectedRow = tableView.selectedRow
        if selectedRow == -1 { return }
        
        print(selectedRow)
        tableView.deselectRow(selectedRow)
        
        let alertViewController = AuthenticationAlertWindowController()
        alertViewController.delegate = self
        alertViewController.service = services[selectedRow]
        alertViewController.showWindow(nil)
        alertViewController.window?.center()
        NSApp.runModal(for: alertViewController.window!)
    }
}

extension SMBListViewController: AuthenticationDelegate {
    func authentication(authentication: Authentication?) {
        if let authentication,
           case let Authentication.registerUser(userName, password, service) = authentication {
            print(authentication)
            _ = mountSMBShare(
                url: URL(string: "smb://\(service.smbService.ipv4!)")!,
                username: userName,
                password: password
            )
        }
    }
}

#Preview {
    SMBListViewController()
}
