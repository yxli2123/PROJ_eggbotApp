//
//  MyPicViewController.swift
//  EggBot
//
//  Created by Yixiao Li on 2019/12/25.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

import UIKit

class MyPicViewController: UIViewController{
    var Xposition = [UInt8].init()
    var Yposition = [UInt8].init()
    var delegate: myPicDelegate?
    
    @IBAction func No1(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_Totoro() as! [UInt8]
        Yposition = OpenCV.resultDataY_Totoro() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    @IBAction func No2(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_IcebergBear() as! [UInt8]
        Yposition = OpenCV.resultDataY_IcebergBear() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    @IBAction func No3(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_Spongebob() as! [UInt8]
        Yposition = OpenCV.resultDataY_Spongebob() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    @IBAction func No4(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_DoraAmen() as! [UInt8]
        Yposition = OpenCV.resultDataY_DoraAmen() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    @IBAction func CWK(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_CWK() as! [UInt8]
        Yposition = OpenCV.resultDataY_CWK() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    @IBAction func Picaqiu(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_PKQ() as! [UInt8]
        Yposition = OpenCV.resultDataY_PKQ() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    @IBAction func PJ(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_PJ() as! [UInt8]
        Yposition = OpenCV.resultDataY_PJ() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    
    @IBAction func GT(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_GT() as! [UInt8]
        Yposition = OpenCV.resultDataY_GT() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    
    @IBAction func DLS(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_DLS() as! [UInt8]
        Yposition = OpenCV.resultDataY_DLS() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    @IBAction func PDX(_ sender: Any) {
        Xposition.removeAll()
        Yposition.removeAll()
        Xposition = OpenCV.resultDataX_PDX() as! [UInt8]
        Yposition = OpenCV.resultDataY_PDX() as! [UInt8]
        delegate?.SendDataToBluetoothFromMyPic(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
protocol myPicDelegate {
     func SendDataToBluetoothFromMyPic(sendDataPositionX :[UInt8], sendDataPositionY: [UInt8])
}
