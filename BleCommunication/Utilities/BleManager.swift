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
    
    @Published var foundPeripherals: [Peripheral] = []
    @Published var foundServices: [Service] = []
    @Published var foundCharacteristics: [Characteristic] = []
    
    static let shared = BleManager()
    
    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral? = nil
    
    // MARK: Initiator
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    // MARK: Public Functions
    func connectPeripheral(_ selectedPeripheral: CBPeripheral?) {
        guard let selectedPeripheral = selectedPeripheral else { return }
        centralManager.connect(selectedPeripheral, options: nil)
    }
    
    func disconnectPeripheral() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(connectedPeripheral)
    }
    
    // MARK: CBCentralManagerDelegate
    func didUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case.poweredOn:
            isBlePowerOn = true
        default:
            isBlePowerOn = false
        }
    }
    
    func didDiscover(_ central: CBCentralManager, peripheral: CBPeripheral, advertisementData: [String : Any], rssi: Int) {
        guard
            rssi >= 0,
            let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        else { return }
        
        let discoveredPeripheral = Peripheral(peripheral: peripheral, name: peripheralName, advertisementData: advertisementData, rssi: rssi, discoverCount: 0)
        
        if let index = foundPeripherals.firstIndex(where: { $0.peripheral.identifier.uuidString == peripheral.identifier.uuidString}) {
            let foundPeripheral = foundPeripherals[index]
            foundPeripherals[index] = foundPeripheral
                .updateRssi(rssi: rssi)
                .increaseDiscoverCount()
        } else {
            foundPeripherals.append(discoveredPeripheral)
        }
    }
    
    func didConnect(_ central: CBCentralManager, peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        
        guard let connectedPeripheral = connectedPeripheral else { return }
        
        connectedPeripheral.delegate = self
        connectedPeripheral.discoverServices(nil)
        isConnected = true
    }
    
    func didFailToConnect(_ central: CBCentralManager, peripheral: CBPeripheral) {
        disconnectPeripheral()
    }
    
    func didDisconnectPeripheral(_ central: CBCentralManager, peripheral: CBPeripheral, error: Error?) {
        guard let error = error else {
            cleanAll()
            return
        }
        
        logError(error: error)
    }
    
    func willRestoreState(_ central: CBCentralManager, dict: [String : Any]) {
        
    }
    
    func connectionEventDidOccur(_ central: CBCentralManager, event: CBConnectionEvent, peripheral: CBPeripheral) {
        
    }
    
    func didUpdateANCSAuthorization(_ central: CBCentralManager, peripheral: CBPeripheral) {
        
    }
    
    // MARK: CBPeripheralDelegate
    func didDiscoverServices(_ peripheral: CBPeripheral, error: Error?) {
        guard let error = error else {
            peripheral.services?.forEach { service in
                let discoveredService = Service(uuid: service.uuid, service: service)
                
                foundServices.append(discoveredService)
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            return
        }
        
        logError(error: error)
    }
    
    func didDiscoverCharacteristics(_ peripheral: CBPeripheral, service: CBService, error: Error?) {
        guard let error = error else {
            service.characteristics?.forEach { characteristic in
                let discoveredCharacteristic = Characteristic(characteristic: characteristic, description: "", uuid: characteristic.uuid, readValue: "", service: service)
                
                foundCharacteristics.append(discoveredCharacteristic)
                peripheral.readValue(for: characteristic)
            }
        
            return
        }
        
        logError(error: error)
    }
    
    func didUpdateValue(_ peripheral: CBPeripheral, characteristic: CBCharacteristic, error: Error?) {
        guard let error = error else {
            guard let value = characteristic.value else { return }
            
            if let index = foundCharacteristics.firstIndex(where: { $0.uuid.uuidString == characteristic.uuid.uuidString }) {
                let newValue = value.map({ String(format: "%02X", $0) }).joined()
                let foundCharacteristic = foundCharacteristics[index]
                foundCharacteristics[index] = foundCharacteristic.updateReadValue(readValue: newValue)
            }
            
            return
        }
        
        logError(error: error)
    }
    
    // MARK: Private Functions
    private func cleanAll() {
        isScanning = false
        isConnected = false
        
        foundPeripherals.removeAll()
        foundServices.removeAll()
    }
    
    private func logError(error: Error) {
        print(error.localizedDescription)
    }
}
