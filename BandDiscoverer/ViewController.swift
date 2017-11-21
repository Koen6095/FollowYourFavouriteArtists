//
//  ViewController.swift
//  BandDiscoverer
//
//  Created by Koen Vestjens on 30/10/2017.
//  Copyright © 2017 Koen Vestjens. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var txtArtistSearch: UITextField!
    var jsonEvents: JSON = ""
    
    var rootURL: String = "https://app.ticketmaster.com/discovery/v2/"
    var apiKey: String = "4OcCJjg1iekcisI2hHsw5bTgwAXRV1Gg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAttractionID(completionHandler: @escaping (String?, Error?) -> ()) {
        getResponse(completionHandler: completionHandler)
    }
    
    func getResponse(completionHandler: @escaping (String?, Error?) -> ()) {
        let searchText: String = txtArtistSearch.text!.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url: String = "https://app.ticketmaster.com/discovery/v2/attractions.json?apikey=4OcCJjg1iekcisI2hHsw5bTgwAXRV1Gg&keyword=\(searchText)"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response  in
                switch response.result {
                case .success(let value):
                    let json = JSON(response.data)
                    let id: String = json["_embedded"]["attractions"][0]["id"].string!
                    completionHandler(id, nil)
                case .failure(let error):
                    completionHandler(nil, error)
                }
        }
    }
    
    //test
    
    @IBAction func btnSearch(_ sender: UIButton) {
        
        getAttractionID() { id, error in
            // use responseObject and error here
            
            if(error == nil){
                
                var url: String = self.rootURL
                 
                 //Get a list of all events in the United States
                 var artistSearch: String = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=4OcCJjg1iekcisI2hHsw5bTgwAXRV1Gg&attractionId=\(String(describing: id!))"
                
                 Alamofire.request(artistSearch, method: .get, parameters: nil, encoding: JSONEncoding.default)
                 .responseJSON { response in
                 //to get status code
                    if let status = response.response?.statusCode {
                        switch(status){
                            case 200:
                                print("example success: \(status)")
                                
                                let json = JSON(response.data)
                                let events: JSON = json["_embedded"]
                                self.jsonEvents = events
                                self.performSegue(withIdentifier: "segueShowBand", sender: self)
                            case 201:
                                print("example success: \(status)")
                            default:
                                print("error with response status: \(status)")
                        }
                    }
                 
                 }
            }
            return
        }
    }
    
    func getAttractionID() -> String? {
        
        let searchText: String = txtArtistSearch.text!.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        let url: String = "https://app.ticketmaster.com/discovery/v2/attractions.json?apikey=4OcCJjg1iekcisI2hHsw5bTgwAXRV1Gg&keyword=\(searchText)"
        var attractionID: String?
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response  in
                //to get status code
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        print("example success")
                        //print(response)
                        
                        let json = JSON(response.data)
                        let id: String = json["_embedded"]["attractions"][0]["id"].string!
                        attractionID = id
                    case 201:
                        print("example success")
                    default:
                        print("error with response status: \(status)")
                    }
                }
        }
        
        return attractionID
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier){
            case "segueShowBand"?:
                if let bvc = segue.destination as? BandViewController {
                    bvc.jsonEvents = self.jsonEvents
                    bvc.artistName = self.txtArtistSearch.text!
                }
            break
            default: break
        }
    }
}

