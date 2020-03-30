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

class PlayWeb : UIViewController, WKUIDelegate {
    
    static let notificationYouTubeClearIds = "YouTubeClearIds"
    static let notificationYouTubeInsertId = "YouTubeInsertId"
    static let notificationYouTubeLoadById = "YouTubeLoadById"
    var youtube: WKWebView? // YouTube Player
    
    override func viewDidLoad() {
        self.view.isHidden = true
        self.view.layoutIfNeeded()
        let notificationClearIds = Notification.Name(PlayWeb.notificationYouTubeClearIds)
        NotificationCenter.default.addObserver(self, selector: #selector(clear), name: notificationClearIds, object: nil)
        let notificationInsertId = Notification.Name(PlayWeb.notificationYouTubeInsertId)
        NotificationCenter.default.addObserver(self, selector: #selector(insert), name: notificationInsertId, object: nil)
        let notificationLoadById = Notification.Name(PlayWeb.notificationYouTubeLoadById)
        NotificationCenter.default.addObserver(self, selector: #selector(unhide), name: notificationLoadById, object: nil)
    }
    
    func countdown() {
        youtube?.evaluateJavaScript("countdown();", completionHandler: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.countdown()
        }
    }
    
    @objc func clear() {
        youtube?.evaluateJavaScript("clearPlaylist();", completionHandler: nil)
    }
    
    @objc func insert(notification: NSNotification) {
        let songId: String = notification.userInfo?[DataNotation.ID] as? String ?? ""
        youtube?.evaluateJavaScript("addVideoById('" + songId + "');", completionHandler: nil)
    }
    
    @objc func unhide(notification: NSNotification) {
        let songId: String = notification.userInfo?[DataNotation.ID] as? String ?? ""
        youtube?.evaluateJavaScript("loadVideoById('" + songId + "');", completionHandler: nil)
        if (self.view.isHidden) {
            self.view.isHidden = false
            self.view.layoutIfNeeded()
            countdown()
        }
    }
    
    override func viewWillLayoutSubviews() {
        let webview = WKWebView(frame: self.view.bounds)
        webview.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
        webview.configuration.preferences.javaScriptEnabled = true
        webview.configuration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            webview.configuration.mediaTypesRequiringUserActionForPlayback = .video
        }
        webview.uiDelegate = self
        youtube = webview
        view.addSubview(youtube!)
        if let filePath = Bundle.main.url(forResource: "youtube", withExtension: "html") {
          let request = NSURLRequest(url: filePath)
          youtube?.load(request as URLRequest)
        }        
    }
    
    func webView(_ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert);
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) { _ in completionHandler()} );
        self.present(alert, animated: true, completion: {});
    }
}
