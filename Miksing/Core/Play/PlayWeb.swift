//
//  PlayWeb.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-24.
//  Copyright © 2020 Tregz. All rights reserved.
//

import AVKit
import UIKit
import WebKit

class PlayWeb : UIViewController {
    
    var youtube: WKWebView? // YouTube Player
    
    override func viewDidLoad() {
        self.view.isHidden = true
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(unhide), name: Notification.Name("YouTubePlay"), object: nil)
    }
    
    @objc func unhide(notification: NSNotification) {
        let songId: String = notification.userInfo?["id"] as? String ?? ""
        print("youtubeId: " + songId)
        youtube?.evaluateJavaScript("loadVideoById('" + songId + "');", completionHandler: nil)
        if (self.view.isHidden) {
            self.view.isHidden = false
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillLayoutSubviews() {
        let webview = WKWebView(frame: self.view.bounds)
        webview.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        youtube = webview
        view.addSubview(youtube!)
        if let filePath = Bundle.main.url(forResource: "youtube", withExtension: "html") {
          let request = NSURLRequest(url: filePath)
          youtube?.load(request as URLRequest)
        }        
    }
}
