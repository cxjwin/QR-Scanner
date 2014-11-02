//
//  ViewController.swift
//  CWQRCodeScanner
//
//  Created by cxjwin on 10/30/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit
import AVFoundation

let kLayerWidth: CGFloat = 280.0

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    class CornerView: UIView {
        override func drawRect(rect: CGRect) {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
            
            let lineLength: CGFloat = 15.0
            
            var bezierPath = UIBezierPath()
            bezierPath.lineWidth = 2
            bezierPath.moveToPoint(CGPoint(x: rect.minX, y: rect.minY + lineLength))
            bezierPath.addLineToPoint(CGPoint(x: rect.minX, y: rect.minY))
            bezierPath.addLineToPoint(CGPoint(x: rect.minX + lineLength, y: rect.minY))
            bezierPath.stroke()
            
            bezierPath = UIBezierPath()
            bezierPath.lineWidth = 2
            bezierPath.moveToPoint(CGPoint(x: rect.maxX - lineLength, y: rect.minY))
            bezierPath.addLineToPoint(CGPoint(x: rect.maxX, y: rect.minY))
            bezierPath.addLineToPoint(CGPoint(x: rect.maxX, y: rect.minY + lineLength))
            bezierPath.stroke()

            bezierPath = UIBezierPath()
            bezierPath.lineWidth = 2
            bezierPath.moveToPoint(CGPoint(x: rect.maxX, y: rect.maxY - lineLength))
            bezierPath.addLineToPoint(CGPoint(x: rect.maxX, y: rect.maxY))
            bezierPath.addLineToPoint(CGPoint(x: rect.maxX - lineLength, y: rect.maxY))
            bezierPath.stroke()

            bezierPath = UIBezierPath()
            bezierPath.lineWidth = 2
            bezierPath.moveToPoint(CGPoint(x: rect.minX + lineLength, y: rect.maxY))
            bezierPath.addLineToPoint(CGPoint(x: rect.minX, y: rect.maxY))
            bezierPath.addLineToPoint(CGPoint(x: rect.minX, y: rect.maxY - lineLength))
            bezierPath.stroke()
        }
    }
    
    lazy var cornerView: CornerView = {
        let width = kLayerWidth + 2
        let height = kLayerWidth + 2
        let _cornerView = CornerView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        _cornerView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(_cornerView)
        
        return _cornerView;
    }();
    
    lazy var captureLayer: AVCaptureVideoPreviewLayer = {
        // session
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        // input
        var error : NSError?
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let input = AVCaptureDeviceInput(device: device, error: &error)
        if input == nil {
            println(error!.description)
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // output
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
        }
        
        // layer
        let _layer = AVCaptureVideoPreviewLayer(session: session)
        _layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        _layer.frame = CGRect(x: 1, y: 1, width: kLayerWidth, height: kLayerWidth);
        
        assert(self.isViewLoaded(), "is view loaded")
        self.cornerView.layer.insertSublayer(_layer, atIndex: 0)
        
        return _layer;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "扫码"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let bounds = self.view.bounds
        
        var cornerViewFrame = self.cornerView.frame
        cornerViewFrame.origin.x = bounds.midX - self.cornerView.bounds.midX
        cornerViewFrame.origin.y = bounds.midY - self.cornerView.bounds.midY
        self.cornerView.frame = cornerViewFrame
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.captureLayer.session.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureLayer.session.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects.count > 0 {
            var metadataObject = metadataObjects[0] as AVMetadataMachineReadableCodeObject
            
            let stringValue = metadataObject.stringValue
            
            println("stringValue : \(stringValue)")
            
            self.captureLayer.session.stopRunning()
            
            let alertController = UIAlertController(title: "是否打开", message: stringValue, preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (let action: UIAlertAction!) -> Void in
                let URL = NSURL(string: "http://\(stringValue)")
                
                var canOpen = false
                if let _URL = URL {
                    canOpen = true
                    
                    self.performSegueWithIdentifier("OpenURL", sender: _URL)
                }
                
                if !canOpen {
                    self.captureLayer.session.startRunning()
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { [unowned self] (let action: UIAlertAction!) -> Void in
                self.captureLayer.session.startRunning()
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destinationViewController as? WebController {
            controller.URL = sender as? NSURL
        }
    }
}

