//
//  LibraryViewController.swift
//  EggBot
//
//  Created by Yixiao Li on 2019/12/1.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, myPicDelegate{
    
    func SendDataToBluetoothFromMyPic(sendDataPositionX: [UInt8], sendDataPositionY: [UInt8]) {
        delegate?.SendDataToBluetoothFromLib(sendDataPositionX: sendDataPositionX, sendDataPositionY: sendDataPositionY)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? MyPicViewController {
        destination.delegate = self
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    var resultImage: UIImage!
    var canny_output: UIImage!
    var image: UIImage!
    
    var addCoef = 0.25
    var threshold: Int32 = 127
    
    var Xposition = [UInt8]()
    var Yposition = [UInt8]()
    
    var isImageLoaded: Bool = false;
    var isImageProcessed: Bool = false;
    
    var delegate: LibDataDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didPressSend(_ sender: Any) {
        delegate?.SendDataToBluetoothFromLib(sendDataPositionX: Xposition, sendDataPositionY: Yposition)
    }
    
    @IBAction func didPreview(_ sender: Any) {
        if(isImageProcessed){
            resultImage = OpenCV.result(canny_output, addcoef: addCoef)
            imageView.image = resultImage
            Xposition = OpenCV.resultDataX(canny_output, addcoef: addCoef) as! [UInt8]
            Yposition = OpenCV.resultDataY(canny_output, addcoef: addCoef) as! [UInt8]
        }
    }

    @IBAction func thresholdPress(_ sender: UISlider) {
        threshold = Int32(sender.value)
        if(isImageLoaded) {
            canny_output = OpenCV.previewImage(image, thresh: threshold)
            imageView.image = canny_output
        }
    }
    @IBAction func didPressLib(_ sender: Any) {
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
            () -> Void in
            })
        }else{
            print("读取相册错误")
        }
    }
    
    //选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //显示的图片
        image = info[.originalImage] as? UIImage
        canny_output = OpenCV.previewImage(image, thresh: threshold)
        imageView.image = canny_output
        isImageLoaded = true
        isImageProcessed = true
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
    }
    
}

protocol LibDataDelegate{
    func SendDataToBluetoothFromLib(sendDataPositionX :[UInt8], sendDataPositionY: [UInt8])
}
