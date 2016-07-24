//
//  TracksViewController.swift
//  SoundcloudMobile
//
//  Created by Matthew Wolfe on 7/23/16.
//  Copyright © 2016 Matthew Wolfe. All rights reserved.
//

import UIKit

class TracksViewController: UITableViewController {
    
    var controller: Controller = Controller()
    var tracks:[Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.controller = Controller(callback: {() in
            self.tracks = self.controller.downloader.remoteTracks
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("TrackCell", forIndexPath: indexPath)
            
            let track = tracks[indexPath.row] as Track
            cell.textLabel?.text = track.title
            cell.detailTextLabel?.text = track.getDuration()
            return cell
    }

}
