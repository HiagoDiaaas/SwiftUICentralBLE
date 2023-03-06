//
//  BLECentralView.swift
//  SwiftUICentralBLE
//
//  Created by Hiago Santos Martins Dias on 06/03/23.
//

import SwiftUI
import CoreBluetooth

struct BLECentralView: View {
    
    @StateObject var viewModel = BLECentralViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.peripherals) { peripheral in
                        HStack {
                            Text(peripheral.name ?? "Unknown")
                            Spacer()
                            if peripheral.isConnected {
                                Button(action: {
                                    viewModel.disconnect(from: peripheral)
                                }, label: {
                                    Text("Disconnect")
                                })
                            } else {
                                Button(action: {
                                    viewModel.connect(to: peripheral)
                                }, label: {
                                    Text("Connect")
                                })
                            }
                        }
                    }
                }
                HStack {
                    Text("Peripheral Name: ")
                    Text("\(viewModel.selectedPeripheral?.name ?? "")")
                }
                HStack {
                    Text("Peripheral Status: ")
                    Text("\(viewModel.selectedPeripheral?.isConnected ?? false ? "Connected" : "Not connected")")
                }
                HStack {
                    Text("Characteristic Value: ")
                    Text("\(viewModel.selectedCharacteristic?.value ?? "")")
                }
                TextField("Write data to characteristic", text: $viewModel.writeData)
                    .padding(.horizontal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    Button(action: {
                        viewModel.startScanning()
                    }, label: {
                        Text("Scan")
                    })
                    Button(action: {
                        viewModel.readValue(from: viewModel.selectedCharacteristic!)
                    }, label: {
                        Text("Read")
                    })
                    Button(action: {
                        viewModel.writeValue(to: viewModel.selectedCharacteristic!)
                    }, label: {
                        Text("Write")
                    })
                }
                
                .navigationBarTitle("Bluetooth Central")
            }
        }
    }
}
