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
    
    func testExample() {
        XCTAssertEqual(3, setUpUnderTest.items.count)
    }
    
    // MARK: test functions
    func testGetCityFromLocation(){
        
        let locationAmsterdam: CLLocation = CLLocation(latitude: 51.451936369010838,
                                                       longitude: 5.4811685008439843)
        
        setUpUnderTest.getCityFromLocation(location: locationAmsterdam) { (city) in
            XCTAssertEqual(city, "Amsterdam", "Returned wrong city name")
        }
    }
}
