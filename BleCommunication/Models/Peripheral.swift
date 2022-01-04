//
//  Peripheral.swift
//  BleCommunication
//
//  Created by Gary Wu (008689) on 2022/1/4.
//

import CoreBluetooth

struct Peripheral: Identifiable {
    let id = UUID().uuidString
    let peripheral: CBPeripheral
    let name: String
    let advertisementData: [String: Any]
    let rssi: Int
    let discoverCount: Int
    
    init(peripheral: CBPeripheral, name: String, advertisementData: [String: Any], rssi: Int, discoverCount: Int) {
        self.peripheral = peripheral
        self.name = name
        self.advertisementData = advertisementData
        self.rssi = rssi
        self.discoverCount = discoverCount
    }
    
    func increaseDiscoverCount() -> Peripheral {
        return Peripheral(peripheral: peripheral, name: name, advertisementData: advertisementData, rssi: rssi, discoverCount: discoverCount + 1)
    }
    
    func updateRssi(rssi: Int) -> Peripheral {
        return Peripheral(peripheral: peripheral, name: name, advertisementData: advertisementData, rssi: rssi, discoverCount: discoverCount)
    }
}
