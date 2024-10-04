//
//  SMBTableCell.swift
//  SMBBrowser
//
//  Created by Anbalagan on 05/09/24.
//

import Cocoa

final class SMBTableCell: NSTableCellView {
    static let cellIdentifier = NSUserInterfaceItemIdentifier("SMBTableCell")
    
    private var computerNameTextField: NSTextField!
    private var computerIPTextField: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func updateLayer() {
        super.updateLayer()
        layer?.backgroundColor = NSColor.tableCellBackground.cgColor
    }
    
    func setupData(computerName: String, address: String) {
        computerNameTextField.stringValue = computerName
        computerIPTextField.stringValue = address
    }
}

private extension SMBTableCell {
    func setupView() {
        identifier = SMBTableCell.cellIdentifier

        let networkDriveImageView = NSImageView(image: .networkDrive)
        networkDriveImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(networkDriveImageView)
        
        let dividerBoxView = NSBox()
        dividerBoxView.translatesAutoresizingMaskIntoConstraints = false
        dividerBoxView.boxType = .separator
        addSubview(dividerBoxView)
        
        computerNameTextField = NSTextField()
        computerNameTextField.translatesAutoresizingMaskIntoConstraints = false
        computerNameTextField.isEditable = false
        computerNameTextField.drawsBackground = false
        computerNameTextField.isBezeled = false
        computerNameTextField.textColor = NSColor.textColor
        computerNameTextField.maximumNumberOfLines = 1
        addSubview(computerNameTextField)
        
        computerIPTextField = NSTextField()
        computerIPTextField.translatesAutoresizingMaskIntoConstraints = false
        computerIPTextField.isEditable = false
        computerIPTextField.drawsBackground = false
        computerIPTextField.isBezeled = false
        computerIPTextField.textColor = NSColor.textColor
        computerIPTextField.maximumNumberOfLines = 1
        addSubview(computerIPTextField)
        
        NSLayoutConstraint.activate([
            networkDriveImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            networkDriveImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            networkDriveImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            networkDriveImageView.widthAnchor.constraint(equalTo: networkDriveImageView.heightAnchor),
            
            dividerBoxView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dividerBoxView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dividerBoxView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dividerBoxView.heightAnchor.constraint(equalToConstant: 1),
            
            computerNameTextField.leadingAnchor.constraint(equalTo: networkDriveImageView.trailingAnchor, constant: 8),
            computerNameTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            computerNameTextField.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            
            computerIPTextField.leadingAnchor.constraint(equalTo: networkDriveImageView.trailingAnchor, constant: 8),
            computerIPTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            computerIPTextField.topAnchor.constraint(equalTo: computerNameTextField.bottomAnchor, constant: 4)
        ])
    }
}
