//
//  Track.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/17/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import Foundation

struct Track {
    let name: String
    let url: NSURL
    let duration: Double
    
    init(name: String, url: NSURL, duration: Double){
        self.name = name
        self.url = url
        self.duration = duration
    }
    
    func getDuration() -> String {
        return "\(self.duration / 3600):\((self.duration % 3600) / 60):\((self.duration % 3600) % 60)"
    }
}