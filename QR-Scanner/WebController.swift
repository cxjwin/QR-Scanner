//
//  WebController.swift
//  CWQRCodeScanner
//
//  Created by cxjwin on 11/2/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit
import WebKit

class WebController: UIViewController {

    var URL: NSURL?
	
	@IBOutlet weak var progressView: UIProgressView!
	
	lazy var webView: WKWebView = {
		let bounds = self.view.bounds
		let _webView = WKWebView(frame: bounds)
		assert(self.isViewLoaded(), "is view loaded")
		self.view.addSubview(_webView)
		return _webView
	}()
	
	deinit {
		webView.removeObserver(self, forKeyPath: "estimatedProgress")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if URL != nil {
            let request = NSURLRequest(URL: URL!)
            webView.loadRequest(request)
        }
		
		webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
    }

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		webView.frame = view.bounds
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	// MARK: - KVO
	
	override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
		if keyPath == "estimatedProgress" {
			let value = change[NSKeyValueChangeNewKey] as Double
			progressView.progress = Float(value)
		}
	}
}
