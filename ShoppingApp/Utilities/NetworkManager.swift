//
//  NetworkManager.swift
//  ShoppingApp
//
//  Created by Biene Bryle Sanico on 4/2/25.
//

import Combine
import Network

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let monitorNetwork = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitoringQueue")
    @Published var isConnected: Bool = true
    
    private init() {
        monitorNetwork.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitorNetwork.start(queue: queue)
    }
}
