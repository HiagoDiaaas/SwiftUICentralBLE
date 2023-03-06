//
//  BLECharacteristic.swift
//  SwiftUICentralBLE
//
//  Created by Hiago Santos Martins Dias on 06/03/23.
//

import CoreBluetooth

struct BLECharacteristic: Identifiable {
    var id: UUID {
        return UUID(uuidString: characteristic.uuid.uuidString)!
    }
    
    let characteristic: CBCharacteristic
    var value: String? = nil
    
    init(characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
}


