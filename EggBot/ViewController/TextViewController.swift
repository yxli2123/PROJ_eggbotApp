//
//  TextViewController.swift
//  EggBot
//
//  Created by Yixiao Li on 2019/12/18.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

import UIKit

class TextViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var preCanva: UIImageView!
    
    var textPreview: UIImage!
    var addCoef = 0.0
    var letters: String = ""
    var Xposition = [UInt8]()
    var Yposition = [UInt8]()
    var delegate: TextDataDelegate?
    var fontType = Int32.init()
    
    let textField = UITextField(frame: CGRect(x:406,y:160,width:300,height:30))
    
    @IBAction func Black(_ sender: Any) {
        fontType = 1
        textField.placeholder = "You've chosen Black"
    }
    @IBAction func Duplex(_ sender: Any) {
        fontType = 2
        textField.placeholder = "You've chosen Duplex"
    }
    @IBAction func Plain(_ sender: Any) {
        fontType = 3
        textField.placeholder = "You've chosen Plain"
    }
    @IBAction func ScriptSimplex(_ sender: Any) {
        fontType = 4
        textField.placeholder = "You've chosen Script Simplex"
    }
    @IBAction func Simplex(_ sender: Any) {
        fontType = 5
        textField.placeholder = "You've chosen Simplex"
    }
    @IBAction func Triplex(_ sender: Any) {
        fontType = 6
        textField.placeholder = "You've chosen Triplex"
    }
    @IBAction func Italic(_ sender: Any) {
        fontType = 7
        textField.placeholder = "You've chosen Italic"
    }
    @IBAction func Normal(_ sender: Any) {
        fontType = 8
        textField.placeholder = "You've chosen Normal"
    }
    
    @IBAction func didPressDraw(_ sender: Any) {
        if delegate != nil{
            delegate?.SendDataToBluetoothFromText(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置边框样式为圆角矩形
        textField.clearButtonMode = UITextField.ViewMode.always
        textField.placeholder = "Choose a font first"
        textField.keyboardType = UIKeyboardType.asciiCapable
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.returnKeyType = UIReturnKeyType.done
        textField.delegate = self
        self.view.addSubview(textField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        letters = textField.text!
        textPreview = OCVLetter.previewText(letters,font: fontType)
        textPreview = OpenCV.result(textPreview, addcoef: 0.0)
        preCanva.image = textPreview
        Xposition = OCVLetter.letterResultDataX(letters,font: fontType) as! [UInt8]
        Yposition = OCVLetter.letterResultDataY(letters,font: fontType) as! [UInt8]
        return true
    }
}
protocol TextDataDelegate {
    func SendDataToBluetoothFromText(sendDataPositionX :[UInt8], sendDataPositionY: [UInt8])
}
