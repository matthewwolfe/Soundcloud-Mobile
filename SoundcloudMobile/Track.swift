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
    let url: URL
    let duration: Double
    
    init(title: String, url: URL, duration: Double){
        self.title = title
        self.url = url
        self.duration = duration
    }
    
    func getDuration() -> String {
        let hours = Int(self.duration / 3600)
        let minutes = Int(((self.duration.truncatingRemainder(dividingBy: 3600)) / 60))
        let seconds = Int(((self.duration % 3600).truncatingRemainder(dividingBy: 60)))
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        
        if hours == 0 {
            return "\(formatter.string(from: NSNumber(minutes))!):\(formatter.string(from: seconds)!)"
        } else {
            return "\(formatter.string(from: NSNumber(hours))!):\(formatter.string(from: minutes)!):\(formatter.string(from: seconds)!)"
        }
    }
}
