//
//  Track.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/17/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import Foundation

struct Track {
    let title: String
    let url: NSURL
    let duration: Double
    
    init(title: String, url: NSURL, duration: Double){
        self.title = title
        self.url = url
        self.duration = duration
    }
    
    func getDuration() -> String {
        let hours = Int(self.duration / 3600)
        let minutes = Int(((self.duration % 3600) / 60))
        let seconds = Int(((self.duration % 3600) % 60))
        
        let formatter = NSNumberFormatter()
        formatter.minimumIntegerDigits = 2
        
        if hours == 0 {
            return "\(formatter.stringFromNumber(minutes)!):\(formatter.stringFromNumber(seconds)!)"
        } else {
            return "\(formatter.stringFromNumber(hours)!):\(formatter.stringFromNumber(minutes)!):\(formatter.stringFromNumber(seconds)!)"
        }
    }
}