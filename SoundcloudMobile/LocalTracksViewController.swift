//
//  LocalTracksViewController.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/24/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

//
//  TracksViewController.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/23/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import UIKit

class LocalTracksViewController: UITableViewController {
    
    var controller: Controller = Controller()
    var tracks:[Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset.top = 20
        
        self.controller = Controller(callback: {() in
            self.tracks = self.controller.downloader.localTracks
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath)
            
            let track = tracks[indexPath.row] as Track
            cell.textLabel?.text = track.title
            cell.detailTextLabel?.text = track.getDuration()
            return cell
    }
    
}
