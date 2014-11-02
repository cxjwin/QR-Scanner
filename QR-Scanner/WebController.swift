//
//  WebController.swift
//  CWQRCodeScanner
//
//  Created by cxjwin on 11/2/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import UIKit

class WebController: UIViewController {

    var URL: NSURL?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if URL != nil {
            let request = NSURLRequest(URL: URL!)
            self.webView.loadRequest(request)
        }
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

}
