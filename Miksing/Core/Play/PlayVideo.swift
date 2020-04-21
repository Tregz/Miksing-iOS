//
//  CorePlayer.swift
//  Miksing
//
//  Created by Jerome Robbins on 2020-03-23.
//  Copyright © 2020 Tregz. All rights reserved.
//

import AVKit
import FirebaseStorage

class PlayVideo : AVPlayerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemOrange
        //loadURL(reference: "anim/Miksing_Logo-Animated.mp4")
        loadMP4("logo-animated")
        let name = NSNotification.Name.AVPlayerItemDidPlayToEndTime
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in
            self.player?.seek(to: CMTime.zero)
            self.player?.play()
        }
    }
    
    private func loadMP4(_ reference: String) {
        if let url = Bundle.main.url(forResource: reference, withExtension: "mp4") {
            self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
            self.player?.play()
        }
    }
    
    private func loadURL(_ reference: String) {
        let anim = Storage.storage().reference().child(reference)
        anim.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                self.player = AVPlayer(playerItem: AVPlayerItem(url: url!))
                self.player?.play()
            }
        }
    }
    
}
