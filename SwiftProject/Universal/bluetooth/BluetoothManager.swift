//
//  S_BluetoothManger.swift
//  Start
//
//  Created by cloud on 2025/7/17.
//

//MARK: 设备特征值

let UUID_Service = "6E400001-B5A3-F393-E0A9-E50E24DCCA9D"
let UUID_Write_Char = "6E400001-B5A3-F393-E0A9-E50E24DCCA9D"
let UUID_Notify_Char = "6E400001-B5A3-F393-E0A9-E50E24DCCA9D"

import UIKit
import CoreBluetooth

enum BluetoothState {
    case poweredOn
    case poweredOff
    case unauthorized
    case unknown
}
class STDeviceModel:NSObject{
    
    var peripheral:CBPeripheral!
    
    var name:String = ""
    
    var mac:String = ""

    var rssi:NSNumber = 0

    
}

class S_BluetoothManger: NSObject {

    static let shared = S_BluetoothManger()
    
    var centralManager:CBCentralManager?

    var writeCharacter:CBCharacteristic?
    
    var connectPeripheral: CBPeripheral?
    
    
    private var peripherals:[CBPeripheral]?
    
    
    var updateState: ((Bool)->Void)?
    
    var updateConnect:((Bool)->Void)?
    
    var canSendData:((Bool)->Void)?
    
    var updatePerpherals:((Array<STDeviceModel>)->Void)?
    /**
     *  蓝牙状态是否开启
     */
    var isPoweredOn:Bool?
    
    var state:BluetoothState?

    var deviceModels:Array<STDeviceModel> = []
    
    /**
     *   绑定 蓝牙设备名字
     */
    var deviceName:String = ""
    
    var isBind:Bool = false

    var isReconnection:Bool = false

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: [CBCentralManagerOptionShowPowerAlertKey:false])
    }

    func startScan(serviceUUIDS:[CBUUID]? = nil, options:[String: Any]? = nil) {
        self.retryConnect() // 为了获取已连接的蓝牙 设备
    }
    func stopScan() {
        centralManager?.stopScan()
    }
    func connectPerpheral(peripheral:CBPeripheral) {
        if(state != .poweredOn){
            return
        }
        self.centralManager?.connect(peripheral, options: nil)
    }
    func cancelPeripheral() {
        guard let peripheral = self.connectPeripheral else {
            return
        }
        if(state != .poweredOn){
            return
        }
        self.centralManager?.cancelPeripheralConnection(peripheral)
    }
    func writeCommand(data:NSData){
        guard let peripheral = self.connectPeripheral else {
            return
        }
        guard let write = self.writeCharacter else {
            return
        }
        if(data.count > 0){
            peripheral.writeValue(data as Data, for: write, type: .withResponse)
        }

    }
    func retryConnect(){
        peripherals = self.centralManager?.retrieveConnectedPeripherals(withServices: [CBUUID(string: UUID_Service)])
        for peripheral in peripherals ?? [] {
            let model = STDeviceModel()
            model.peripheral = peripheral
            model.name = peripheral.name ?? ""
            model.mac = "已连接"
            model.rssi = 0
            if(!deviceModels.contains(where: { $0.name == model.name })){
                deviceModels.append(model)
            }
            self.updatePerpherals?(deviceModels)
            if(peripheral.name == self.deviceName){
                self.connectPerpheral(peripheral: peripheral)
            }
        }
        self.centralManager?.scanForPeripherals(withServices: nil)
    }

}
extension S_BluetoothManger: CBCentralManagerDelegate {
    // 检测蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.state = .poweredOn
            if(self.connectPeripheral?.state == .disconnected){
                guard let peripheral = self.connectPeripheral else { return }
                self.connectPerpheral(peripheral: peripheral)
            }else{
                self.retryConnect()
            }
            print("蓝牙已开启，开始扫描设备")
        case .poweredOff:
            self.state = .poweredOff
            print("蓝牙未开启")
        case .unauthorized:
            self.state = .unauthorized
            print("应用程序未被授权使用蓝牙低功耗功能")
        case .unsupported:
            self.state = .unknown
            print("该设备不支持蓝牙低功耗功能")
        case .resetting:
            self.state = .unknown
            print("与系统服务的连接暂时丢失")
        case .unknown:
            self.state = .unknown
            print("蓝牙未开启")
        default: break
        }
        
        if(self.state == .poweredOn){
            self.isPoweredOn = true
        }else{
            self.isPoweredOn = false
        }
        self.updateState?(self.isPoweredOn!)

        
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if ((peripheral.name ?? "").isEmpty) {
            return
        }
        print("发现设备: \(peripheral.name ?? "未知设备"), RSSI: \(RSSI)")
        
        //过滤非 星迈手环 蓝牙
        var macString = ""
        var manufacturerStr = ""
        guard let data:NSData = advertisementData["kCBAdvDataManufacturerData"] as? NSData else{
            return
        }
        if(data.count >= 6){ //最后6位MAC地址
            let macBuf = [UInt8](repeating: 0, count: 6)
            let unsafeMacBuf = UnsafeMutableRawBufferPointer.allocate(byteCount: macBuf.count, alignment: 1)

            if data.count > 8 { // 带数据广播地址
                data.copyBytes(to: unsafeMacBuf, from: 2..<8)
            } else {
                data.copyBytes(to: unsafeMacBuf, from: (data.count-6)..<data.count)
            }

            for i in 0..<6 {
                let hexStr = String(format: "%02X", unsafeMacBuf[i] & 0xff)
                if i == 0 {
                    macString += hexStr
                } else {
                    macString += ":\(hexStr)"
                }
            }

            let manufacturer = [UInt8](repeating: 0, count: 2)
            let unsafeManufacturer = UnsafeMutableRawBufferPointer.allocate(byteCount: manufacturer.count, alignment: 1)
            data.copyBytes(to: unsafeManufacturer, from: 0..<2)
            manufacturerStr = String(format: "<%02X%02X>", unsafeManufacturer[0] & 0xff, unsafeManufacturer[1] & 0xff)
        }
        if(manufacturerStr != "<0001>"){//生产商家
            return
        }
        let name = peripheral.name ?? ""
        if (name.hasSuffix("-0000")) {///设备Mac异常
            return
        }
        
        let model = STDeviceModel()
        model.peripheral = peripheral
        model.name = peripheral.name ?? ""
        model.mac = macString
        model.rssi = RSSI
        if(!deviceModels.contains(where: { $0.name == model.name })){
            deviceModels.append(model)
        }
        self.updatePerpherals?(deviceModels)
        
        // 根据设备名或 UUID 筛选目标设备
        if peripheral.name?.contains(self.deviceName) == true && self.isReconnection{
            centralManager?.connect(peripheral, options: nil)
        }
    }
    // 连接成功回调
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("连接成功: \(peripheral.name ?? "") : \(peripheral.state)")
        self.connectPeripheral = peripheral
        peripheral.delegate = self
        self.deviceName = peripheral.name ?? ""
        
        self.stopScan()
        peripheral.discoverServices(nil) // 发现所有服务
        
        self.updateConnect?(true)
    }

    // 连接失败回调
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("连接失败: \(error?.localizedDescription ?? "")")
        self.updateConnect?(false)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("设备断开，尝试重连...")
        if(!self.deviceName.isEmpty){
            central.connect(peripheral, options: nil)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        // 服务变更时触发（配对成功后常见）
        
    }

}
extension S_BluetoothManger: CBPeripheralDelegate {
    // 发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("发现服务: \(service.uuid)")
            // 发现服务的特征
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // 发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        if(service.uuid.uuidString == UUID_Service){
            for characteristic in characteristics {
                print("特征 UUID: \(characteristic.uuid)")
                let uuidString = characteristic.uuid.uuidString
                if(uuidString == UUID_Write_Char){
                    self.writeCharacter = characteristic
                    self.canSendData?(true)
                }
                if(uuidString == UUID_Notify_Char){
                    peripheral.setNotifyValue(true, for: characteristic)
                }
//                // 订阅通知（如需接收数据）
//                if characteristic.properties.contains(.notify) {
//                    peripheral.setNotifyValue(true, for: characteristic)
//                }
//                // 读取特征值
//                peripheral.readValue(for: characteristic)
            }

        }
    }
    
    // 接收数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if((error) != nil){
            
        }else{
            
        }
    }

    // 写入数据（需特征支持写入）
    func writeData(to characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        let data = "Hello BLE".data(using: .utf8)!
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }

}

