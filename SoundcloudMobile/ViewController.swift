//
//  ViewController.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/16/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let downloader = Downloader(callback: {(url: NSURL) in
            self.playSound(url)
        })
    }
    
    func playSound(url: NSURL){
        print(url)
        
        do{
            self.audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            self.audioPlayer.prepareToPlay()
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            self.audioPlayer.play()
            print("playing")
        } catch {
            print("Error getting the audio file")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

