//
//  SwiftUICentralBLEApp.swift
//  SwiftUICentralBLE
//
//  Created by Hiago Santos Martins Dias on 06/03/23.
//

import SwiftUI

@main
struct SwiftUICentralBLEApp: App {
    var body: some Scene {
        WindowGroup {
            BLECentralView(viewModel: BLECentralViewModel())
        }
    }
}

