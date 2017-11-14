//
//  SetUpViewController.swift
//  BandDiscoverer
//
//  Created by Koen Vestjens on 08/11/2017.
//  Copyright © 2017 Koen Vestjens. All rights reserved.
//

import UIKit
import MapKit

class SetUpViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewDistanceFromSupplement: UIView!
    @IBOutlet weak var txtDistanceFrom: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewAutoCompletion: UITableView!
    @IBOutlet weak var txtDistanceTo: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    //location services
    let locationManager = CLLocationManager()
    var locationFrom: CLLocation = CLLocation()
    var locationTo: CLLocation = CLLocation()
    let geoCoder = CLGeocoder()
    
    //textfield
    var activeTextfield: UITextField = UITextField()
    
    var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    
    var items: [String] = ["Amsterdam", "Amstelveen", "Amstelrade"]
    var isTyping: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegates
        locationManager.delegate = self
        txtDistanceFrom.delegate = self
        txtDistanceTo.delegate = self
        mapView.delegate = self
        tableViewAutoCompletion.delegate = self
        scrollView.delegate = self
        
        //tap gesture
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        //btn scroll up
        let btnScrollUp: UIButton = UIButton(frame: CGRect(x: 25, y: 25, width: 50, height: 50))
        btnScrollUp.backgroundColor = UIColor.green
        btnScrollUp.setTitle("Up", for: .normal)
        btnScrollUp.addTarget(self, action: #selector(scrollUpAction), for: .touchUpInside)
            
        //map view
        mapView.addSubview(btnScrollUp)
        
        //table view
        tableViewAutoCompletion.dataSource = self
        tableViewAutoCompletion.allowsSelection = true
        
        viewDistanceFromSupplement.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func scrollUpAction(sender:UIButton! ){
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc func dismissKeyboard() {
        
        var location: CGPoint = tapGesture.location(in: self.tableViewAutoCompletion)
        var path: IndexPath? = self.tableViewAutoCompletion.indexPathForRow(at: location)
        if path == nil {
            // tap was not on tableview
            if(txtDistanceFrom.isFirstResponder){
                txtDistanceFrom.resignFirstResponder()
            }
            if(txtDistanceTo.isFirstResponder){
                txtDistanceTo.resignFirstResponder()
            }
            
            
            UIView.animate(withDuration: 1, animations: {
                self.stackView.removeArrangedSubview(self.viewDistanceFromSupplement)
                self.stackView.setNeedsLayout()
                self.stackView.layoutIfNeeded()
                
                self.viewDistanceFromSupplement.isHidden = true
            }, completion: nil)
        }
    }

    func getLocationFromAddress(address: String, completion: @escaping (_ foundLocation: CLLocation)->()) {
        //get location from
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            guard
                let placemarks = placemarks,
                let location: CLLocation = placemarks.first?.location
                else {
                    print("location not found.")
                    // handle no location found
                    let alertController = UIAlertController(title: "Location not found", message:
                        "Please insert another location.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    return
            }
            completion(location)
        })
    }
    
    func getCityFromLocation(location: CLLocation, completion: @escaping (_ foundCity: String)->()){
        let location = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // City
            if let city = placeMark.locality as NSString? {
                print(city)
                completion(city as String)
            }
        })
    }
    
    func drawCircleOnMapFrom(location: CLLocation, toLocation: CLLocation){
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let distanceInMeters = toLocation.distance(from: location)
        
        mapView.removeOverlays(mapView.overlays)
        mapView.add(MKCircle(center: center, radius: distanceInMeters))
    }
    
    //location services
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("locationManager called")
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        //print("latitude: \(location!.coordinate.latitude) - longitude: \(location!.coordinate.longitude)")
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        
        //set location from to current location
        self.locationFrom = location!
        getCityFromLocation(location: location!) { (city) in
            self.txtDistanceFrom.text = city
        }
        
        //stop updating location
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    func checkTextFieldsIfEmpty(){
        if(txtDistanceFrom.text?.count != 0 && txtDistanceTo.text?.count != 0){
            //drawcircle
            drawCircleOnMapFrom(location: self.locationFrom, toLocation: self.locationTo)
        }
    }
    
    @IBAction func setCurrentLocationAction(_ sender: UIButton) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
    }
    
    // MARK: textfield delegate functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.stackView.removeArrangedSubview(self.viewDistanceFromSupplement)
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.viewDistanceFromSupplement.isHidden = true
        
        self.stackView.removeArrangedSubview(self.viewDistanceFromSupplement)
        self.stackView.setNeedsLayout()
        self.stackView.layoutIfNeeded()
        
        switch(textField.tag){
        case 1:
            //textfield from
            if(isTyping != true){
                UIView.animate(withDuration: 1, animations: {
                    self.stackView.insertArrangedSubview(self.viewDistanceFromSupplement, at: 1)
                    self.stackView.setNeedsLayout()
                    
                    self.viewDistanceFromSupplement.isHidden = false
                    self.tableViewAutoCompletion.reloadData()
                    self.tapGesture.cancelsTouchesInView = false
                    
                    self.activeTextfield = textField
                }, completion: nil)
            }
            break
        case 2:
            //textfield to
            if(isTyping != true){
                UIView.animate(withDuration: 1, animations: {
                    self.stackView.insertArrangedSubview(self.viewDistanceFromSupplement, at: 2)
                    self.stackView.setNeedsLayout()
                    
                    self.viewDistanceFromSupplement.isHidden = false
                    self.tapGesture.cancelsTouchesInView = false
                    
                    self.activeTextfield = textField
                }, completion: nil)
            }
            break
        default: break
        }
        
        isTyping = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch(textField.tag){
        case 1:
            //textfield from
            
            getLocationFromAddress(address: self.txtDistanceFrom.text!) { (location) in
                self.locationFrom = location
                print(location.coordinate.latitude)
                print(location.coordinate.longitude)
                self.checkTextFieldsIfEmpty()
            }
           
            break
        case 2:
            //textfield to
            getLocationFromAddress(address: self.txtDistanceTo.text!) { (location) in
                self.locationTo = location
                self.checkTextFieldsIfEmpty()
            }
            break
        default: break
        }
        
        isTyping = false
    }
    
    // MARK: scroll view delegate functions
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    // MARK: map view delegate functions
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("mapView called")
        
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.blue
            circleRenderer.alpha = 0.3
            return circleRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
    
    // MARK: table view delegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell.textLabel?.text = self.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCompletion", for: indexPath) as! CompletionTableViewCell
        cell.lblCompletion.text = items[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! CompletionTableViewCell
        
        switch (activeTextfield.tag) {
        case 1:
            //textfield from
            self.txtDistanceFrom.text = currentCell.lblCompletion!.text
            break
        case 2:
            //textfield from
            self.txtDistanceTo.text = currentCell.lblCompletion!.text
            break
        default: break
        }
    }
    
}
