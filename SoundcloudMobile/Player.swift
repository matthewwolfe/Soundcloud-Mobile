//
//  Player.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/23/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import Foundation
import AVFoundation

class Player {
    
    var audioPlayer: AVAudioPlayer
    
    init(){
        self.audioPlayer = AVAudioPlayer()
    }
    
    func play(url: NSURL) -> Void {
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
    
    func stop() -> Void {
        self.audioPlayer.stop()
    }
    
    func pause() -> Void {
        self.audioPlayer.pause()
    }
    
    func volume(newVolume: Float) -> Void {
        self.audioPlayer.volume = newVolume
    }
}