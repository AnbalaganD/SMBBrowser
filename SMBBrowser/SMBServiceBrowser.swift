//
//  SMBServiceBrowser.swift
//  SMBBrowser
//
//  Created by Anbalagan on 03/09/24.
//

import Foundation

enum ServiceOperation {
    case added
    case removed
}

struct Service {
    let id: String
    let operation: ServiceOperation
    let smbService: SMBService
}

struct SMBService {
    let name: String
    let ipv4: String?
    let shared: [String]?
}

class SMBServiceBrowser: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    private let browser = NetServiceBrowser()
    private var services = [NetService: String]()
    
    private var continuation: AsyncStream<Service>.Continuation?
    
    override init() {
        super.init()
        
        browser.delegate = self
    }
    
    func getServices() -> AsyncStream<Service> {
        let stream = AsyncStream<Service> { continuation in
            self.continuation = continuation
            
            continuation.onTermination = { ternimation in
                print(ternimation)
            }
        }
        startBrowsing()
        return stream
    }
    
    private func startBrowsing() {
        browser.searchForServices(ofType: "_smb._tcp.", inDomain: "local.")
    }
    
    func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didFind service: NetService,
        moreComing: Bool
    ) {
        if let id = services[service] {
            services[service] = id
        } else {
            services[service] = UUID().uuidString
        }
        service.delegate = self
        service.resolve(withTimeout: 10)
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let addresses = sender.addresses else { return }
        
        for addressData in addresses {
            addressData.withUnsafeBytes { pointer in
                let sockaddr = pointer.bindMemory(to: sockaddr.self).baseAddress!
                
                if sockaddr.pointee.sa_family != AF_INET { return }
                
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                var servInfo = [CChar](repeating: 0, count: Int(NI_MAXSERV))
                
                // Try to get the hostname
                if getnameinfo(
                    sockaddr,
                    socklen_t(addressData.count),
                    &hostname,
                    socklen_t(hostname.count),
                    &servInfo,
                    socklen_t(servInfo.count),
                    NI_NUMERICHOST | NI_NUMERICSERV
                ) == 0 {
                    let ipAddress = String(cString: hostname)
                    if let id = services[sender] {
                        continuation?.yield(
                            Service(
                                id: id,
                                operation: .added,
                                smbService: SMBService(
                                    name: sender.name,
                                    ipv4: ipAddress,
                                    shared: nil
                                )
                            )
                        )
                    }
                }
            }
        }
    }
    
    func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didRemove service: NetService,
        moreComing: Bool
    ) {
        if let id = services[service] {
            services[service] = nil
            continuation?.yield(
                Service(
                    id: id,
                    operation: .removed,
                    smbService:
                        SMBService(
                            name: service.name,
                            ipv4: nil,
                            shared: nil
                        )
                )
            )
        }
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Stopped searching.")
    }
    
    func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didNotSearch errorDict: [String: NSNumber]
    ) {
        print(errorDict)
    }
}
