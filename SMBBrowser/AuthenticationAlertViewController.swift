//
//  AuthenticationAlertViewController.swift
//  SMBBrowser
//
//  Created by Anbalagan on 06/09/24.
//

import Cocoa

enum Authentication {
    case guest
    case registerUser(
        userName: String,
        password: String,
        service: Service
    )
}

protocol AuthenticationDelegate: NSObject {
    func authentication(
        authentication: Authentication?
    )
}

final class AuthenticationAlertViewController: NSViewController {
    weak var delegate: AuthenticationDelegate?
    
    private var appearenceObserver: NSKeyValueObservation?
    
    private var titleDescriptionTextField: NSTextField!
    private var guestButton: NSButton!
    private var registeredUserButton: NSButton!
    private var nameTitleLabel: NSTextField!
    private var passwordTitleLabel: NSTextField!
    private var nameTextField: NSTextField!
    private var passwordTextField: NSTextField!
    private var guestModeConstraint = [NSLayoutConstraint]()
    private var registeredUserModeConstraint = [NSLayoutConstraint]()
    
    private let service: Service
    init(service: Service) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addNotificationObserver()
        setupData()
    }
    
    private func setupData() {
        titleDescriptionTextField.stringValue = "Enter your name and password for the sever \"\(service.smbService.name)\""
    }
    
    @objc private func cancelTapped() {
        view.window?.close()
        NSApp.abortModal()
    }
    
    @objc private func connectTapped() {
        delegate?.authentication(
            authentication: .registerUser(
                userName: nameTextField.stringValue,
                password: passwordTextField.stringValue,
                service: service
            )
        )
        view.window?.close()
        NSApp.abortModal()
    }
    
    @objc private func onRadioButtonTapped(_ sender: NSButton) {
        if sender == guestButton {
            guestButton.state = .on
            registeredUserButton.state = .off
            
            nameTitleLabel.isHidden = true
            passwordTitleLabel.isHidden = true
            nameTextField.isHidden = true
            passwordTextField.isHidden = true
            
            NSLayoutConstraint.deactivate(registeredUserModeConstraint)
            NSLayoutConstraint.activate(guestModeConstraint)
            view.needsLayout = true
        } else {
            guestButton.state = .off
            registeredUserButton.state = .on
            
            nameTitleLabel.isHidden = false
            passwordTitleLabel.isHidden = false
            nameTextField.isHidden = false
            passwordTextField.isHidden = false
            
            NSLayoutConstraint.deactivate(guestModeConstraint)
            NSLayoutConstraint.activate(registeredUserModeConstraint)
            view.needsLayout = true
        }
    }
}

private extension AuthenticationAlertViewController {
    func setupView() {
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 500).isActive = true
        
        let networkDriveImageView = NSImageView(image: .networkDrive)
        networkDriveImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(networkDriveImageView)
        
        titleDescriptionTextField = NSTextField()
        titleDescriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        titleDescriptionTextField.drawsBackground = false
        titleDescriptionTextField.isBezeled = false
        titleDescriptionTextField.isEditable = false
        titleDescriptionTextField.textColor = .textColor
        titleDescriptionTextField.maximumNumberOfLines = 3
        titleDescriptionTextField.lineBreakMode = .byWordWrapping
        view.addSubview(titleDescriptionTextField)
        
        let connectAsTextField = NSTextField(string: "Connect As:")
        connectAsTextField.translatesAutoresizingMaskIntoConstraints = false
        connectAsTextField.drawsBackground = false
        connectAsTextField.isBezeled = false
        connectAsTextField.isEditable = false
        connectAsTextField.textColor = .textColor
        connectAsTextField.font = .boldSystemFont(ofSize: 13)
        connectAsTextField.maximumNumberOfLines = 3
        view.addSubview(connectAsTextField)
        
        guestButton = NSButton()
        guestButton.translatesAutoresizingMaskIntoConstraints = false
        guestButton.setButtonType(.radio)
        guestButton.title = "Guest"
        guestButton.state = .off
        guestButton.target = self
        guestButton.action = #selector(onRadioButtonTapped)
        view.addSubview(guestButton)
        
        registeredUserButton = NSButton()
        registeredUserButton.translatesAutoresizingMaskIntoConstraints = false
        registeredUserButton.setButtonType(.radio)
        registeredUserButton.title = "Registered User"
        registeredUserButton.state = .on
        registeredUserButton.target = self
        registeredUserButton.action = #selector(onRadioButtonTapped)
        view.addSubview(registeredUserButton)
        
        nameTitleLabel = NSTextField()
        nameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTitleLabel.isEditable = false
        nameTitleLabel.stringValue = "Name:"
        nameTitleLabel.drawsBackground = false
        nameTitleLabel.isBezeled = false
        view.addSubview(nameTitleLabel)
        
        passwordTitleLabel = NSTextField()
        passwordTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTitleLabel.isEditable = false
        passwordTitleLabel.stringValue = "Password:"
        passwordTitleLabel.drawsBackground = false
        passwordTitleLabel.isBezeled = false
        view.addSubview(passwordTitleLabel)
        
        nameTextField = NSTextField()
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.drawsBackground = false
        view.addSubview(nameTextField)
        
        passwordTextField = NSTextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.drawsBackground = false
        view.addSubview(passwordTextField)
        
        let cancelButton = NSButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.title = "Cancel"
        cancelButton.target = self
        cancelButton.action = #selector(cancelTapped)
        view.addSubview(cancelButton)
        
        let connectButton = NSButton()
        connectButton.wantsLayer = true
        connectButton.bezelStyle = .texturedSquare
        connectButton.isBordered = true
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.title = "Connect"
        connectButton.target = self
        connectButton.action = #selector(connectTapped)
        connectButton.layer?.backgroundColor = NSColor.blue.cgColor
        connectButton.layer?.cornerRadius = 6
        view.addSubview(connectButton)
        
        guestModeConstraint.append(contentsOf: [
            view.heightAnchor.constraint(equalToConstant: 180),
            
            cancelButton.topAnchor.constraint(equalTo: registeredUserButton.bottomAnchor, constant: 20),
            connectButton.topAnchor.constraint(equalTo: registeredUserButton.bottomAnchor, constant: 20),
        ])
        
        registeredUserModeConstraint.append(contentsOf: [
            view.heightAnchor.constraint(equalToConstant: 280),
            
            nameTitleLabel.trailingAnchor.constraint(equalTo: connectAsTextField.trailingAnchor),
            nameTitleLabel.topAnchor.constraint(equalTo: registeredUserButton.bottomAnchor, constant: 25),
            
            nameTextField.leadingAnchor.constraint(equalTo: nameTitleLabel.trailingAnchor, constant: 10),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.centerYAnchor.constraint(equalTo: nameTitleLabel.centerYAnchor),
            
            passwordTitleLabel.trailingAnchor.constraint(equalTo: connectAsTextField.trailingAnchor),
            passwordTitleLabel.topAnchor.constraint(equalTo: nameTitleLabel.bottomAnchor, constant: 20),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTitleLabel.trailingAnchor, constant: 10),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordTitleLabel.centerYAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor, constant: 20),
            connectButton.topAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor, constant: 20),
        ])
        
        NSLayoutConstraint.activate([
            networkDriveImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            networkDriveImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            networkDriveImageView.heightAnchor.constraint(equalToConstant: 80),
            networkDriveImageView.widthAnchor.constraint(equalToConstant: 80),
            
            titleDescriptionTextField.leadingAnchor.constraint(equalTo: networkDriveImageView.trailingAnchor, constant: 20),
            titleDescriptionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleDescriptionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            connectAsTextField.leadingAnchor.constraint(equalTo: networkDriveImageView.trailingAnchor, constant: 20),
            connectAsTextField.topAnchor.constraint(equalTo: titleDescriptionTextField.bottomAnchor, constant: 15),
            
            guestButton.leadingAnchor.constraint(equalTo: connectAsTextField.trailingAnchor, constant: 10),
            guestButton.centerYAnchor.constraint(equalTo: connectAsTextField.centerYAnchor),
            
            registeredUserButton.leadingAnchor.constraint(equalTo: connectAsTextField.trailingAnchor, constant: 10),
            registeredUserButton.topAnchor.constraint(equalTo: guestButton.bottomAnchor, constant: 8),
            
            cancelButton.trailingAnchor.constraint(equalTo: connectButton.leadingAnchor, constant: -20),
            
            connectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            connectButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
        ] + registeredUserModeConstraint)
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


#Preview {
    AuthenticationAlertViewController(
        service: Service(
            id: "",
            operation: .added,
            smbService: SMBService(
                name: "Anbalagan D",
                ipv4: nil,
                shared: nil
            )
        )
    )
}
