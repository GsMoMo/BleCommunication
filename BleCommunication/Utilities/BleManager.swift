//
//  BleManager.swift
//  BleCommunication
//
//  Created by Gary Wu (008689) on 2022/1/4.
//

import Foundation
import CoreBluetooth

class BleManager: NSObject, ObservableObject {
    
    @Published var isBlePowerOn: Bool = false
    @Published var isScanning: Bool = false
    @Published var isConnected: Bool = false
    
    static let shared = BleManager()
    
    private var centralManager: CBCentralManager!
    
    private override init() {
        super.init()
        #if targetEnvironment(simulator)
        centralManager = CBCentralManagerMock(delegate: self, queue: nil)
        #else
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        #endif
    }
    
    private func updateState(_ central: CBCentralManager) {
        switch central.state {
        case.poweredOn:
            isBlePowerOn = true
        default:
            isBlePowerOn = false
        }
    }
}

extension BleManager :CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        updateState(central)
    }
}
