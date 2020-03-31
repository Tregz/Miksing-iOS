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
    var ytSafari: WKWebView? = nil
    var ytWeb: UIWebView? = nil
    
    override func loadView() {
        if #available(iOS 11.0, *) {
            ytSafari = WKWebView(frame: .zero)
            ytSafari!.configuration.preferences.javaScriptEnabled = true
            ytSafari!.configuration.allowsInlineMediaPlayback = true
            ytSafari!.uiDelegate = self // enable javascript alert message
            view = ytSafari!
        } else {
            ytWeb = UIWebView()
            ytWeb!.allowsInlineMediaPlayback = true
            view = ytWeb!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isHidden = true
        self.view.layoutIfNeeded()
        let notificationClearIds = Notification.Name(PlayWeb.notificationYouTubeClearIds)
        NotificationCenter.default.addObserver(self, selector: #selector(clear), name: notificationClearIds, object: nil)
        let notificationInsertId = Notification.Name(PlayWeb.notificationYouTubeInsertId)
        NotificationCenter.default.addObserver(self, selector: #selector(insert), name: notificationInsertId, object: nil)
        let notificationLoadById = Notification.Name(PlayWeb.notificationYouTubeLoadById)
        NotificationCenter.default.addObserver(self, selector: #selector(unhide), name: notificationLoadById, object: nil)
        if let filePath = Bundle.main.url(forResource: "youtube", withExtension: "html") {
            let request = URLRequest(url: filePath)
            if #available(iOS 11.0, *) { ytSafari!.load(request) }
            else { ytWeb!.loadRequest(request) }
        }
    }
    
    func countdown() {
        evaluateJavaScript(javascript: "countdown();")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { self.countdown() }
    }
    
    @objc func clear() {
        evaluateJavaScript(javascript: "clearPlaylist();")
    }
    
    @objc func insert(notification: NSNotification) {
        let songId: String = notification.userInfo?[DataNotation.ID] as? String ?? ""
        evaluateJavaScript(javascript: "addVideoById('" + songId + "');")
    }
    
    private func evaluateJavaScript(javascript: String) {
        if #available(iOS 11.0, *) { ytSafari?.evaluateJavaScript(javascript, completionHandler: nil) }
        else { ytWeb?.stringByEvaluatingJavaScript(from: javascript) }
    }
    
    @objc func unhide(notification: NSNotification) {
        let songId: String = notification.userInfo?[DataNotation.ID] as? String ?? ""
        evaluateJavaScript(javascript: "loadVideoById('" + songId + "');")
        if (self.view.isHidden) {
            self.view.isHidden = false
            self.view.layoutIfNeeded()
            countdown()
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
