//
//  BandViewController.swift
//  BandDiscoverer
//
//  Created by Koen Vestjens on 31/10/2017.
//  Copyright © 2017 Koen Vestjens. All rights reserved.
//

import UIKit
import SwiftyJSON

class BandViewController: UIViewController, UITableViewDelegate,  UITableViewDataSource{
    
    @IBOutlet weak var lblArtistName: UILabel!
    @IBOutlet weak var tableViewEvents: UITableView!
    
    var jsonEvents: JSON = ""
    var artistName: String = ""
    
    var events: [String: String] = [:]
    struct Objects {
        
        var eventName : String!
        var json : JSON!
    }
    var eventsArray = [Objects]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewEvents.delegate = self
        self.tableViewEvents.dataSource = self
        
        self.lblArtistName.text = self.artistName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for (key, subJson) in jsonEvents["events"] {
            if let eventName = subJson["name"].string {
                eventsArray.append(Objects(eventName: eventName, json: subJson))
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventsTableViewCell = self.tableViewEvents.dequeueReusableCell(withIdentifier: "eventsCell") as! EventsTableViewCell
        cell.eventName?.text = eventsArray[indexPath.row].eventName
        cell.promotorName?.text = eventsArray[indexPath.row].json["promoter"]["name"].string
        
        return cell
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    
}


//https://stackoverflow.com/questions/31136084/how-can-i-group-tableview-items-from-a-dictionary-in-swift
