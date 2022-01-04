//
//  Service.swift.swift
//  BleCommunication
//
//  Created by Gary Wu (008689) on 2022/1/4.
//

import CoreBluetooth

struct Service: Identifiable {
    let id = UUID().uuidString
    let uuid: CBUUID
    let service: CBService
    
    init(uuid: CBUUID, service: CBService) {
        self.uuid = uuid
        self.service = service
    }
}
