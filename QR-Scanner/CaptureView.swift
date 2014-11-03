//
//  CaptureView.swift
//  QR-Scanner
//
//  Created by cxjwin on 11/3/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureView: UIView {
	
	let captureLayer: AVCaptureVideoPreviewLayer!
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		backgroundColor = UIColor.clearColor()
		
		captureLayer = {
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
			if session.canAddOutput(output) {
				session.addOutput(output)
				output.metadataObjectTypes = [AVMetadataObjectTypeQRCode];
			}
			
			// layer
			let _layer = AVCaptureVideoPreviewLayer(session: session)
			_layer.videoGravity = AVLayerVideoGravityResizeAspectFill
			let width = self.bounds.width - 2
			let height = self.bounds.height - 2
			_layer.frame = CGRect(x: 1, y: 1, width: width, height: height)
			self.layer.insertSublayer(_layer, atIndex: 0)
			
			return _layer;
		}()
	}
	
	override var bounds: CGRect {
		didSet {
			if (bounds != oldValue && captureLayer != nil) {
				let width = bounds.width - 2
				let height = bounds.height - 2
				captureLayer.frame = CGRect(x: 1, y: 1, width: width, height: height)
			}
		}
	}
	
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
		let context = UIGraphicsGetCurrentContext()
		CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
		
		let lineLength: CGFloat = rect.width * 0.1
		
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

	func startRunning() {
		captureLayer.session.startRunning()
	}
	
	func stopRunning() {
		captureLayer.session.stopRunning()
	}
	
	func setMetadataObjectsDelegate(objectsDelegate: AVCaptureMetadataOutputObjectsDelegate!, queue objectsCallbackQueue: dispatch_queue_t!) {
		let metadataObjects = captureLayer.session.outputs as [AVCaptureOutput]
		for metadataObject in metadataObjects {
			if let object = metadataObject as? AVCaptureMetadataOutput {
				object.setMetadataObjectsDelegate(objectsDelegate, queue: objectsCallbackQueue)
			}
		}
	}
}
