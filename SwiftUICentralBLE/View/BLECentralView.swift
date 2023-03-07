//
//  BLECentralView.swift
//  SwiftUICentralBLE
//
//  Created by Hiago Santos Martins Dias on 06/03/23.
//

import SwiftUI
import CoreBluetooth

import SwiftUI

struct BLECentralView: View {
    @ObservedObject var viewModel: BLECentralViewModel
    
    var body: some View {
        VStack {
            Text("Bluetooth central device").font(.title)
            TextField("Enter text here", text: $viewModel.textFieldValue).padding()
            Button("Read", action: viewModel.readValue).padding()
            Button("Write", action: { viewModel.writeValue(viewModel.textFieldValue) }).padding()
            Spacer()
        }.padding()
        .onAppear(perform: viewModel.startScanning)
        .onDisappear(perform: viewModel.stopScanning)
    }
}

