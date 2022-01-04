//
//  Characteristic.swift
//  BleCommunication
//
//  Created by Gary Wu (008689) on 2022/1/4.
//

import CoreBluetooth

struct Characteristic: Identifiable {
    let id = UUID().uuidString
    let characteristic: CBCharacteristic
    let description: String
    let uuid: CBUUID
    let readValue: String
    var service: CBService
    
    init(characteristic: CBCharacteristic, description: String, uuid: CBUUID, readValue: String, service: CBService) {
        self.characteristic = characteristic
        self.description = description
        self.uuid = uuid
        self.readValue = readValue
        self.service = service
    }
}
