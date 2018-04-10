//
//  ViewController.swift
//  Firma
//
//  Created by Ricardo Champa on 10/04/2018.
//  Copyright © 2018 Ricardo Champa. All rights reserved.
//

import UIKit
import PDFGenerator

class ViewController: UIViewController {
    
    @IBOutlet weak var canvas: UIImageView!
    
    //stores the last drawn point on the canvas. This is used when a continuous brush stroke is being drawn on the canvas.
    var lastPoint = CGPoint.zero
    
    //the current RGB values of the selected color.
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    //the brush stroke width and opacity
    var brushWidth: CGFloat = 10.0
    
    //the brush opacity
    var opacity: CGFloat = 1.0
    
    //identifies if the brush stroke is continuous
    var swiped = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setBlackColor()
    }
    
    
    func setBlackColor() {
        red = 0
        green = 0
        blue = 0
    }
    //UIViewController is a subclass of UIResponder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if !swiped {
            // draw a single point
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        // 6
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        canvas.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2
        let fPoint = CGPoint(x:fromPoint.x, y:fromPoint.y)
        let tPoint = CGPoint(x:toPoint.x, y:toPoint.y)
        context?.move(to: fPoint)
        context?.addLine(to: tPoint)
        
        // 3
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        // 4
        context?.strokePath()
        
        // 5
        canvas.image = UIGraphicsGetImageFromCurrentImageContext()
        canvas.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
}
private extension ViewController{
    @IBAction func exportSign(_ sender: Any) {
        
        UIGraphicsBeginImageContext(canvas.bounds.size)
        canvas.image?.draw(in: CGRect(x: 0, y: 0,width: canvas.frame.size.width, height: canvas.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
//        let activity = UIActivityViewController(activityItems: [image!], applicationActivities: nil)
//        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
//        present(activity, animated: true, completion: nil)
        
        let objectsToShare: [AnyObject] = [image!]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func clearCanvas(_ sender: Any) {
        canvas.image = nil
    }
    
    @IBAction func generatePDF(_ sender: Any) {
        let dst = URL(fileURLWithPath: NSTemporaryDirectory().appending("sign.pdf"))
        // outputs as Data
        //        do {
        //            let data = try PDFGenerator.generated(by: [canvas])
        //            data.write(to: dst, options: .atomic)
        //        } catch (let error) {
        //            print(error)
        //        }
        
        // writes to Disk directly.
        do {
            try PDFGenerator.generate([canvas], to: dst)
        } catch (let error) {
            print(error)
        }
    }
    
}


