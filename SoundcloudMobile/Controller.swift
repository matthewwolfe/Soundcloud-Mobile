//
//  Controller.swift
//  SoundcloudMobile
//
//  Handles everything that goes on in the app
//
//  Created by Matthew Wolfe on 7/23/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import Foundation


class Controller {
    
    let downloader: Downloader
    
    init(){
        self.downloader = Downloader()
    }
    
    init(callback: () -> ()){
        self.downloader = Downloader(callback: {() in
            callback()
        })
    }
}