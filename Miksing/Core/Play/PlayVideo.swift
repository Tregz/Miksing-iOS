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
        let anim = Storage.storage().reference().child("anim/Miksing_Logo-Animated.mp4")
        anim.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                let item = AVPlayerItem(url: url!)
                NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
                    self.player?.seek(to: CMTime.zero)
                    self.player?.play()
                }
                self.player = AVPlayer(playerItem: item)
                self.player?.play()
                
            }
        }
    }
    
}
