//
//  BandDiscovererTests.swift
//  BandDiscovererTests
//
//  Created by Koen Vestjens on 30/10/2017.
//  Copyright © 2017 Koen Vestjens. All rights reserved.
//

import XCTest
import CoreLocation
@testable import BandDiscoverer

class BandDiscovererTests: XCTestCase {
    
    var setUpUnderTest: SetUpViewController!
    
    override func setUp() {
        super.setUp()
        
        setUpUnderTest = SetUpViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: test functions
    func testGetCityFromLocation(){
        let locationEindhoven: CLLocation = CLLocation(latitude: 51.451936369010838,
                                                       longitude: 5.4811685008439843)
        let locationString: String = "Eindhoven"
        let expect = expectation(description: "City not found.")
        
        setUpUnderTest.getCityFromLocation(location: locationEindhoven) { (city) in
            if(city == locationString){
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetLocationFromAddress(){
        let locationAmsterdam: CLLocation = CLLocation(latitude: 52.3731663,
                                                       longitude: 4.8906596)
        let locationString: String = "Amsterdam"
        
        let expect = expectation(description: "Address not found.")
        setUpUnderTest.getLocationFromAddress(address: locationString) { (location) in
            if(location.coordinate.latitude == locationAmsterdam.coordinate.latitude &&
                location.coordinate.longitude == locationAmsterdam.coordinate.longitude){
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 10, handler: nil)
    }
}
