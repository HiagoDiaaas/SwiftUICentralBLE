//
//  BLEPeripheral.swift
//  SwiftUICentralBLE
//
//  Created by Hiago Santos Martins Dias on 06/03/23.
//

import CoreBluetooth

struct BLEPeripheral: Identifiable {
    var id: UUID {
        return peripheral.identifier
    }
    
    var peripheral: CBPeripheral // changed to mutable variable
    var name: String? {
        return peripheral.name
    }
    var services: [CBService] = []
    var isConnected: Bool = false
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
}



