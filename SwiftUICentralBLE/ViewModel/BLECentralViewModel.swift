//
//  BLECentralViewModel.swift
//  SwiftUICentralBLE
//
//  Created by Hiago Santos Martins Dias on 06/03/23.
//

import SwiftUI
import CoreBluetooth

class BLECentralViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let SERVICE_UUID = CBUUID(string: "CDD1")
    private let CHARACTERISTIC_UUID = CBUUID(string: "CDD2")
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var characteristic: CBCharacteristic!
    
    @Published var textFieldValue: String = ""
    @Published var isScanning: Bool = false
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        isScanning = true
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
    }
    
    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }
    
    func readValue() {
        if let characteristic = characteristic {
            peripheral.readValue(for: characteristic)
        }
    }
    
    func writeValue(_ value: String) {
        guard let characteristic = characteristic, let data = value.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            stopScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        stopScanning()
        peripheral.delegate = self
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([SERVICE_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        startScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        startScanning()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == CHARACTERISTIC_UUID {
                self.characteristic = characteristic
                peripheral.readValue(for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == CHARACTERISTIC_UUID, let data = characteristic.value else { return }
        DispatchQueue.main.async {
            self.textFieldValue = String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            readValue()
        }
    }
    
    
    }



