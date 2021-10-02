//
//  DrawingViewController.swift
//  EggBot
//
//  Created by Yixiao Li on 2019/11/30.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

import UIKit

class CanvaViewController: UIViewController {
    
    var delegate: CanvaDataDelegate?
    
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 8.0
    var opacity: CGFloat = 1.0
    var swiped = false
     
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    
    var dataArrayX = [Int]()
    var dataArrayY = [Int]()
    
    @IBOutlet weak var mainImageView: UIImageView!  //务必让整个画布充满屏幕，否则下笔点会飘
    @IBOutlet weak var tempImageView: UIImageView!
    
    @IBAction func didPressSendraw(_ sender: Any) {
        delegate?.SendDataToBluetoothFromCanva(sendDataArrayX: dataArrayX, sendDataArrayY: dataArrayY)
    }

    @IBAction func didPressReset(_ sender: Any) {
        mainImageView.image = nil
        dataArrayX.removeAll()
        dataArrayY.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(view.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
      
        context.move(to: fromPoint)
        context.addLine(to: toPoint)
      
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
      
        context.strokePath()
      
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        // write x and y positions in the dataArray which can be passed to the mainViewController
        dataArrayX.append(Int(fromPoint.x))
        dataArrayY.append(Int(fromPoint.y))
        
        UIGraphicsEndImageContext()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      swiped = false
      lastPoint = touch.location(in: view)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      swiped = true
      let currentPoint = touch.location(in: view)
      drawLine(from: lastPoint, to: currentPoint)
      
      lastPoint = currentPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      if !swiped {
        // draw a single point
        drawLine(from: lastPoint, to: lastPoint)
      }
      
      // Merge tempImageView into mainImageView
      UIGraphicsBeginImageContext(mainImageView.frame.size)
      mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
      tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
      mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      tempImageView.image = nil
    }
}

protocol CanvaDataDelegate {
    func SendDataToBluetoothFromCanva(sendDataArrayX :[Int], sendDataArrayY: [Int])
}

