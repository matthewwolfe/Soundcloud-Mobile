//
//  Downloader.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/16/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

class Downloader {
    let documentsDirectory: NSURL
    var files: NSMutableArray
    var filePaths: [NSURL]

    var localTracks: [Track] = []
    
    let hostURL: String = "http://192.168.1.5:3000/music/"
    
    init(callback: (NSURL) -> ()){
        self.documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        self.files = []
        self.filePaths = []
        
        self.localTracks = self.getLocalTracks()
        
        /*
        self.loadFiles({(response: Bool) in
 
            print(self.documentsDirectory, terminator: "\n\n")
            print(self.filePaths[0], terminator: "\n\n")
            
            if response {
                callback(self.filePaths[0])
            }
        })
 */

    }
    
    /**
        This function searches for mp3 files in the documents directory and returns a Track array
        containing the local files
     
        :returns: An array containing the local tracks, of the type Track
    */
    func getLocalTracks() -> [Track] {
        var tracks = [Track]()
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try NSFileManager
                                        .defaultManager()
                                        .contentsOfDirectoryAtURL(self.documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            let mp3FileNames = directoryContents
                               .filter{$0.pathExtension == "mp3"}
                               .flatMap{$0.URLByDeletingPathExtension?.lastPathComponent}
            
        
            let mp3FilePaths = directoryContents
                               .filter{$0.pathExtension == "mp3"}
                               .map{self.documentsDirectory.URLByAppendingPathComponent($0.lastPathComponent!)}
            
            for (index, element) in mp3FileNames.enumerate() {
                let audioAsset = AVURLAsset(URL: mp3FilePaths[index], options: nil)
                
                let track = Track(
                    title: mp3FileNames[index],
                    url: mp3FilePaths[index],
                    duration: audioAsset.duration.seconds
                )
                
                tracks.append(track)
            }
        } catch {
            print("Error setting local tracks")
        }
        
        return tracks
    }
    
    func loadFiles(callback: (Bool) -> ()) -> Void {
        
        self.request({(json: [String: NSArray]) in
            
            for track in json["tracks"]! {
                self.files.addObject(track["title"] as! String)
            }
            
            var completedFiles: Int = 0
            
            
            for file in self.files {
                self.get(self.hostURL + (file as! String), callback: {() in
                    completedFiles = completedFiles + 1;
                    
                    if completedFiles == self.files.count {
                        callback(true)
                    }
                })
            }
            
        })
    }
    
    func get(urlString: String, callback: () -> ()) -> Void {
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        if let audioUrl = NSURL(string: url){
            
            let destinationUrl = self.documentsDirectory.URLByAppendingPathComponent(audioUrl.lastPathComponent! + ".mp3")
            
            // if the file already exists, we can just return now
            if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
                callback()
                
            // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                NSURLSession.sharedSession().downloadTaskWithURL(audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location where error == nil else { return }
                    
                    do {
                        // after downloading your file you need to move it to your destination url
                        try NSFileManager().moveItemAtURL(location, toURL: destinationUrl)
                        self.filePaths.append(destinationUrl)
                        callback()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    func request(callback: ([String:NSArray]) -> ()){
        let urlPath: String = "http://192.168.1.5:3000/get_tracks"
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler:{data, response, error -> Void in
            
            // Handle incoming data like you would in synchronous request
            let reply = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
            
            callback(self.convertStringToDictionary(reply))
        })
        
        task.resume()
        
    }
    
    func convertStringToDictionary(text: String) -> [String:NSArray] {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try (NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:NSArray])
            } catch let error as NSError {
                print(error)
            }
        }
        return [String:NSArray]()
    }
}