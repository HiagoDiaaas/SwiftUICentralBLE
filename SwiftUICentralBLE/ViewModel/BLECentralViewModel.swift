//
//  BLECentralViewModel.swift
//  SwiftUICentralBLE
//
//  Created by Hiago Santos Martins Dias on 06/03/23.
//

import SwiftUI
import CoreBluetooth

class BLECentralViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let SERVICE_UUID = CBUUID(string: "CDD1")
    let CHARACTERISTIC_UUID = CBUUID(string: "CDD2")
    
    @Published var peripherals: [BLEPeripheral] = []
    @Published var selectedPeripheral: BLEPeripheral? = nil
    @Published var selectedCharacteristic: BLECharacteristic? = nil
    
    @Published var characteristicValue: String = ""
    @Published var writeData: String = ""
    
    private var centralManager: CBCentralManager!
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
    }
    
    func connect(to peripheral: BLEPeripheral) {
        selectedPeripheral = peripheral
        selectedPeripheral?.isConnected = true
        selectedPeripheral?.peripheral.delegate = self
        centralManager.connect(peripheral.peripheral, options: nil)
    }

    func disconnect(from peripheral: BLEPeripheral) {
        selectedPeripheral = peripheral
        selectedPeripheral?.isConnected = false
        centralManager.cancelPeripheralConnection(peripheral.peripheral)
    }

    
    func readValue(from characteristic: BLECharacteristic) {
        selectedCharacteristic = characteristic
        selectedPeripheral?.peripheral.readValue(for: characteristic.characteristic)
    }
    
    func writeValue(to characteristic: BLECharacteristic) {
        let data = self.writeData.data(using: .utf8)!
        selectedPeripheral?.peripheral.writeValue(data, for: characteristic.characteristic, type: .withResponse)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth available")
        } else if central.state == .unsupported {
            print("This device does not support Bluetooth")
        } else if central.state == .poweredOff {
            print("Bluetooth is off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let existingPeripheral = peripherals.first { $0.peripheral.identifier == peripheral.identifier }
        if existingPeripheral == nil {
            let newPeripheral = BLEPeripheral(peripheral: peripheral)
            peripherals.append(newPeripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        selectedPeripheral?.peripheral.discoverServices([SERVICE_UUID])
        print("Connected to peripheral: \(peripheral.name ?? "")")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral: \(peripheral.name ?? "")")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from peripheral: \(peripheral.name ?? "")")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        selectedPeripheral?.services = services
        for service in services {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        var bleCharacteristics = [BLECharacteristic]()
        for characteristic in characteristics {
            print("Discovered characteristic: \(characteristic.uuid)")
            if characteristic.uuid == CHARACTERISTIC_UUID {
                let bleCharacteristic = BLECharacteristic(characteristic: characteristic)
                bleCharacteristics.append(bleCharacteristic)
                let cbMutableCharacteristic = CBMutableCharacteristic(
                    type: characteristic.uuid,
                    properties: characteristic.properties,
                    value: characteristic.value,
                    permissions: CBAttributePermissions(rawValue: characteristic.properties.rawValue)
                )
                peripheral.setNotifyValue(true, for: cbMutableCharacteristic)
            }
        }
        let cbMutableService = CBMutableService(
            type: service.uuid,
            primary: service.isPrimary
        )
        cbMutableService.characteristics = bleCharacteristics.map { $0.characteristic }
        if let serviceIndex = selectedPeripheral?.services.firstIndex(where: { $0.uuid == service.uuid }) {
            selectedPeripheral?.services[serviceIndex] = cbMutableService
            selectedPeripheral?.peripheral.discoverDescriptors(for: (cbMutableService.characteristics?.first!)!)
        }
    }






}

           



