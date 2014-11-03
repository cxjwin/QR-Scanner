//
//  ViewController.swift
//  CWQRCodeScanner
//
//  Created by cxjwin on 10/30/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit
import AVFoundation

let kLimitTime: NSTimeInterval = 15.0

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	
	@IBOutlet weak var captureView: CaptureView!
	
	var timer: NSTimer?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "扫码"
		captureView.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        captureView.startRunning()
		timer =
			NSTimer.scheduledTimerWithTimeInterval(kLimitTime, target: self, selector: "timeOut:", userInfo: nil, repeats: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        captureView.stopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects.count > 0 {
            var metadataObject = metadataObjects[0] as AVMetadataMachineReadableCodeObject
            
            let stringValue = metadataObject.stringValue
			
            captureView.stopRunning()
			
            let alertController = UIAlertController(title: "是否打开", message: stringValue, preferredStyle: .Alert)
			
			var URLString: NSString!
			if (stringValue.hasPrefix("http://") || stringValue .hasPrefix("https://")) {
				URLString = stringValue
			} else {
				URLString = "http://\(stringValue)"
			}
			
            alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: { [unowned self] (let action: UIAlertAction!) -> Void in
                let URL = NSURL(string: URLString)
                
                var canOpen = false
                if let _URL = URL {
                    canOpen = true
                    self.performSegueWithIdentifier("OpenURL", sender: _URL)
					if let _timer = self.timer {
						_timer.invalidate()
					}
                }
                
                if !canOpen {
                    self.captureView.startRunning()
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { [unowned self] (let action: UIAlertAction!) -> Void in
                self.captureView.startRunning()
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
	
	func timeOut(timer: NSTimer) {
		timer.invalidate()
		
		let alertController = UIAlertController(title: "提示", message: "捕捉不到二维码,是否继续?", preferredStyle: .Alert)
		
		alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: { [unowned self] (let action: UIAlertAction!) -> Void in
			self.captureView.startRunning()
			self.timer =
				NSTimer.scheduledTimerWithTimeInterval(kLimitTime, target: self, selector: "timeOut:", userInfo: nil, repeats: false)
		}))
		
		alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { [unowned self] (let action: UIAlertAction!) -> Void in
			self.captureView.stopRunning()
		}))
		
		captureView.stopRunning()
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destinationViewController as? WebController {
            controller.URL = sender as? NSURL
        }
    }
}

