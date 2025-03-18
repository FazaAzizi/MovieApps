//
//  NetworkManager.swift
//  MovieApps
//
//  Created by Faza Azizi on 19/03/25.
//

import Foundation
import Network
import RxRelay

class NetworkManager {
    static let shared = NetworkManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    let isConnected = BehaviorRelay<Bool>(value: false)
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected.accept(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}

