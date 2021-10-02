//
//  MainVIewController.swift
//  EggBot
//
//  Created by Yixiao Li on 2019/12/1.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, LibDataDelegate, TextDataDelegate, CanvaDataDelegate{
    
    var dataX = [Data].init()
    var dataY = [Data].init()

    func SendDataToBluetoothFromText(sendDataPositionX: [UInt8], sendDataPositionY: [UInt8]) {
        var DataPositionX = sendDataPositionX
        var DataPositionY = sendDataPositionY
        dataX.removeAll()
        dataY.removeAll()
        DataPositionX.insert(253, at: 0)
        DataPositionY.insert(253, at: 0)
        DataPositionX.insert(251, at: 0)
        DataPositionY.insert(251, at: 0)
        (dataX, dataY) = ArrayToDataViaBluetooth(ArrayX: DataPositionX, ArrayY: DataPositionY)
        for index in 0..<(dataX.count-1){
            self.peripheral?.writeValue(dataX[index], for: self.characteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
        for index in 0..<(dataY.count-1){
            self.peripheral?.writeValue(dataY[index], for: self.characteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    func SendDataToBluetoothFromLib(sendDataPositionX: [UInt8], sendDataPositionY: [UInt8]) {
        var DataPositionX = sendDataPositionX
        var DataPositionY = sendDataPositionY
        dataX.removeAll()
        dataY.removeAll()
        DataPositionX.insert(253, at: 0)
        DataPositionY.insert(253, at: 0)
        DataPositionX.insert(251, at: 0)
        DataPositionY.insert(251, at: 0)
        (dataX, dataY) = ArrayToDataViaBluetooth(ArrayX: DataPositionX, ArrayY: DataPositionY)
        for index in 0..<(dataX.count-1){
            self.peripheral?.writeValue(dataX[index], for: self.characteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
        for index in 0..<(dataY.count-1){
            self.peripheral?.writeValue(dataY[index], for: self.characteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    func SendDataToBluetoothFromCanva(sendDataArrayX: [Int], sendDataArrayY: [Int]) {
        var sendDataPositionX = [UInt8]()
        var sendDataPositionY = [UInt8]()
        dataX.removeAll()
        dataY.removeAll()
        (sendDataPositionX, sendDataPositionY) = positionToDraw(dataArrayX_raw: sendDataArrayX,dataArrayY_raw: sendDataArrayY)
        (dataX, dataY) = ArrayToDataViaBluetooth_canva(ArrayX: sendDataPositionX, ArrayY: sendDataPositionY)
        for index in 0..<(dataX.count){
            self.peripheral?.writeValue(dataX[index], for: self.characteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
        for index in 0..<(dataY.count){
            self.peripheral?.writeValue(dataY[index], for: self.characteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination1 = segue.destination as? CanvaViewController {
            destination1.delegate = self
        }
        if let destination2 = segue.destination as? LibraryViewController {
            destination2.delegate = self
        }
        if let destination3 = segue.destination as? TextViewController {
            destination3.delegate = self
        }
        
    }
    
    private let Service_UUID: String = "2123"        //进入HC-08的AT模式，务必把LUUID和SUUID设置成一样的！！！
    private let Characteristic_UUID: String = "6666"
   
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Eggbot"
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }
}

extension MainViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    // 判断手机蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("unkowen")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
            central.scanForPeripherals(withServices: [CBUUID.init(string: Service_UUID)], options: nil)
        @unknown default:
            print("Default")
        }
    }

    /** 发现符合要求的外设 */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
         //根据外设名称来过滤
        if (peripheral.name?.hasPrefix("Eggbot"))! {
            central.connect(peripheral, options: nil)
        }
        central.connect(peripheral, options: nil)
    }
    
    /** 连接成功 */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.centralManager?.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID.init(string: Service_UUID)])
        print("Connected Successful")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
         print("Connected Unsuccessful")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected")
        // 重新连接
        central.connect(peripheral, options: nil)
    }
    
    /** 发现服务 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service: CBService in peripheral.services! {
            print("外设中的服务有：\(service)")
        }
        //本例的外设中只有一个服务
        let service = peripheral.services?.last
        // 根据UUID寻找服务中的特征
        peripheral.discoverCharacteristics([CBUUID.init(string: Characteristic_UUID)], for: service!)
    }
    
    /** 发现特征 */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic: CBCharacteristic in service.characteristics! {
            print("外设中的特征有：\(characteristic)")
        }
        
        self.characteristic = service.characteristics?.last
        // 读取特征里的数据
        peripheral.readValue(for: self.characteristic!)
        // 订阅
        peripheral.setNotifyValue(true, for: self.characteristic!)
    }
 
    /** 接收到数据 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
     //   let data = characteristic.value
     //   self.textField.text = String.init(data: data!, encoding: String.Encoding.utf8)
    }
    

}

func moveToNext(StartPositionX: Int, StartPositionY: Int, EndPositionX: Int, EndPositionY: Int)->(dataX: [UInt8], dataY: [UInt8]){
    var dataX = [UInt8].init()
    var dataY = [UInt8].init()
    dataX.append(253) // up the pen
    dataY.append(253)
    var X_last = EndPositionX
    var Y_last = EndPositionY
    while(abs(X_last - StartPositionX) > 125){
        if(X_last - StartPositionX > 0){
            dataX.append(250)
            X_last = X_last - 125
        }else{
            dataX.append(0)
            X_last = X_last + 125
        }
        dataY.append(125)
    }
    dataX.append(UInt8(X_last - StartPositionX + 125))
    dataY.append(125)
    while(abs(Y_last - StartPositionY) > 125){
        if(Y_last - StartPositionY > 0){
            dataY.append(250)
            Y_last = Y_last - 125
        }else{
            dataY.append(0)
            Y_last = Y_last + 125
        }
        dataX.append(125)
    }
    dataY.append(UInt8(Y_last - StartPositionY + 125))
    dataX.append(125)
    
    dataX.append(254) //down the pen
    dataY.append(254)
    return (dataX, dataY)
}
func positionToDraw(dataArrayX_raw: [Int], dataArrayY_raw: [Int])-> (dataToDrawX:[UInt8],dataToDrawY:[UInt8]){
    let dataArrayX = dataArrayX_raw
    let dataArrayY = dataArrayY_raw
    var dataToDrawX = [UInt8]()
    var dataToDrawY = [UInt8]()
    var firstY = dataArrayY[0];
    let begin = 400
    dataToDrawX.append(251)  //start to draw
    dataToDrawY.append(251)
    dataToDrawX.append(253)  //up the pen
    dataToDrawY.append(253)
    
    while(abs(firstY - begin) > 125){
        if(firstY - begin > 0){
            dataToDrawY.append(250)
            firstY = firstY - 125
        }else{
            dataToDrawY.append(0)
            firstY = firstY + 125
        }
            dataToDrawX.append(125)
    }
    dataToDrawY.append(UInt8(firstY - begin + 125))
    dataToDrawX.append(UInt8(125))
    dataToDrawY.append(254)  //down the pen and to draw
    dataToDrawX.append(254)
                
    for index in 1..<dataArrayX.count {
        if(abs(dataArrayX[index]-dataArrayX[index-1]) > 32){
            var pathX = [UInt8].init()
            var pathY = [UInt8].init()
            (pathX, pathY) = moveToNext(StartPositionX: dataArrayX[index-1], StartPositionY: dataArrayY[index-1], EndPositionX: dataArrayX[index], EndPositionY: dataArrayY[index])
            dataToDrawX.append(contentsOf: pathX)
            dataToDrawY.append(contentsOf: pathY)
            continue
        }
        if(abs(dataArrayY[index]-dataArrayY[index-1]) > 32){
            var pathX = [UInt8].init()
            var pathY = [UInt8].init()
            (pathX, pathY) = moveToNext(StartPositionX: dataArrayX[index-1], StartPositionY: dataArrayY[index-1], EndPositionX: dataArrayX[index], EndPositionY: dataArrayY[index])
            dataToDrawX.append(contentsOf: pathX)
            dataToDrawY.append(contentsOf: pathY)
            continue
        }
        
        dataToDrawX.append(UInt8(dataArrayX[index]-dataArrayX[index-1]+125))
        dataToDrawY.append(UInt8(dataArrayY[index]-dataArrayY[index-1]+125))
    }
    dataToDrawX.append(253)  //end drawing
    dataToDrawY.append(253)
    dataToDrawX.append(255)  //end drawing
    dataToDrawY.append(255)
    //print(dataToDrawX)
    //print(dataToDrawY)
    return (dataToDrawX, dataToDrawY)
}
func ArrayToDataViaBluetooth_canva(ArrayX:[UInt8],ArrayY:[UInt8])->(dataX:[Data],dataY:[Data]){
    let bluetoothDataX = Data(ArrayX)
    let bluetoothDataY = Data(ArrayY)
        
    let totalX = bluetoothDataX.firstIndex(of: 255)
    let totalY = bluetoothDataY.firstIndex(of: 255)
        
    var bluetoothDataXArray = [Data].init()
    var bluetoothDataYArray = [Data].init()
        // chunk the data by 64
    for index in 0..<(totalX!/64){
        bluetoothDataXArray.append(bluetoothDataX.subdata(in: 64*index..<64*(index+1)))
    }
    bluetoothDataXArray.append(bluetoothDataX.suffix(from: (totalX!/64)*64))
    for index in 0..<(totalY!/64){
        bluetoothDataYArray.append(bluetoothDataY.subdata(in: 64*index..<64*(index+1)))
    }
    bluetoothDataYArray.append(bluetoothDataY.suffix(from: (totalY!/64)*64))
    
    return (bluetoothDataXArray,bluetoothDataYArray)
}

func ArrayToDataViaBluetooth(ArrayX:[UInt8],ArrayY:[UInt8])->(dataX:[Data],dataY:[Data]){
    let bluetoothDataX = Data(ArrayX)
    let bluetoothDataY = Data(ArrayY)
        
    let totalX = bluetoothDataX.firstIndex(of: 255)
    let totalY = bluetoothDataY.firstIndex(of: 255)
        
    var bluetoothDataXArray = [Data].init()
    var bluetoothDataYArray = [Data].init()
        // chunk the data by 64
    for index in 0..<(totalX!/64+1){
        bluetoothDataXArray.append(bluetoothDataX.subdata(in: 64*index..<64*(index+1)))
    }
    bluetoothDataXArray.append(bluetoothDataX.suffix(from: (totalX!/64)*64))
    for index in 0..<(totalY!/64+1){
        bluetoothDataYArray.append(bluetoothDataY.subdata(in: 64*index..<64*(index+1)))
    }
    bluetoothDataYArray.append(bluetoothDataY.suffix(from: (totalY!/64)*64))
    
    return (bluetoothDataXArray,bluetoothDataYArray)
}

