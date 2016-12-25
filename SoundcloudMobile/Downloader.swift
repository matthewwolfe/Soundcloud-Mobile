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
    let documentsDirectory: URL
    var files: NSMutableArray
    var filePaths: [URL]

    var localTracks: [Track] = []
    var remoteTracks: [Track] = []
    
    let hostURL: String = "http://192.168.1.5:3000/music/"
    
    init(){
        self.documentsDirectory = URL()
        self.files = []
        self.filePaths = []
        self.localTracks = []
        self.remoteTracks = []
    }
    
    init(callback: @escaping () -> ()){
        self.documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        self.files = []
        self.filePaths = []
        
        self.localTracks = self.getLocalTracks()
        
        self.getRemoteTracks({() in
            callback()
        })
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
            let directoryContents = try FileManager.default
                                        .contentsOfDirectory(at: self.documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            let mp3FileNames = directoryContents
                               .filter{$0.pathExtension == "mp3"}
                               .flatMap{$0.deletingPathExtension().lastPathComponent}
            
        
            let mp3FilePaths = directoryContents
                               .filter{$0.pathExtension == "mp3"}
                               .map{self.documentsDirectory.appendingPathComponent($0.lastPathComponent)}
            
            for (index, _) in mp3FileNames.enumerated() {
                let audioAsset = AVURLAsset(url: mp3FilePaths[index], options: nil)
                
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
    
    func getRemoteTracks(_ callback: @escaping () -> ()) -> Void {
        
        self.request({(json: [String: NSArray]) in
            
            for track in json["tracks"]! {
                let urlString = self.hostURL + (track["title"] as! String)
                let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
                
                let duration = Int(track["duration"] as! String)!
                
                self.remoteTracks.append(Track(title: track["title"] as! String, url: url!, duration: self.millisToSeconds(duration)))
            }

            callback()
        })
    }
    
    func millisToSeconds(_ millis: Int) -> Double {
        return Double(millis) / 1000.0
    }
    
    func loadFiles(_ callback: @escaping (Bool) -> ()) -> Void {
        
        self.request({(json: [String: NSArray]) in
            
            for track in json["tracks"]! {
                self.files.add(track["title"] as! String)
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
    
    func get(_ urlString: String, callback: @escaping () -> ()) -> Void {
        let url = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        if let audioUrl = URL(string: url){
            
            let destinationUrl = self.documentsDirectory.appendingPathComponent(audioUrl.lastPathComponent + ".mp3")
            
            // if the file already exists, we can just return now
            if FileManager().fileExists(atPath: destinationUrl.path) {
                callback()
                
            // if the file doesn't exist
            } else {
                
                // you can use NSURLSession.sharedSession to download the data asynchronously
                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager().moveItem(at: location, to: destinationUrl)
                        self.filePaths.append(destinationUrl)
                        callback()
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
    }
    
    func request(_ callback: @escaping ([String:NSArray]) -> ()){
        let urlPath: String = "http://192.168.1.5:3000/get_tracks"
        let url: URL = URL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
        
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.httpShouldHandleCookies = false
        
        let task = URLSession.shared.dataTask(with: request, completionHandler:{data, response, error -> Void in
            
            // Handle incoming data like you would in synchronous request
            let reply = NSString(data: data!, encoding: String.Encoding.utf8)! as String
            
            callback(self.convertStringToDictionary(reply))
        })
        
        task.resume()
        
    }
    
    func convertStringToDictionary(_ text: String) -> [String:NSArray] {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try (JSONSerialization.jsonObject(with: data, options: []) as! [String:NSArray])
            } catch let error as NSError {
                print(error)
            }
        }
        return [String:NSArray]()
    }
}
