//
//  SWAPINetworkingTests.swift
//  Lightspeed-DemoTests
//
//  Created by Michael Eid on 7/19/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import XCTest
import Foundation
import Combine

@testable import Lightspeed_Demo

class SWAPINetworkingTests: XCTestCase {
    
    let testTimeout: TimeInterval = 1
    
    var mocks: Mocks!
    var apiService: SWAPIService!
    
    override func setUp() {
        // URLProtocolMock.setup()
        Current = Environment()
        mocks = Mocks()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        
        let session = URLSession(configuration: config)
        apiService = SWAPIService()
        apiService.session = session
        
    }
    
    override func tearDown() {
        self.mocks = nil
        Current = nil
        
        apiService = SWAPIService()
        
        URLProtocolMock.response = nil
        URLProtocolMock.error = nil
        URLProtocolMock.testURLs = [URL?: Data]()
    }
    
    
    func testGetPeopleRequest() {
        let future = try? apiService.getPeoplePublisher()
        let request =  future?.request
        XCTAssertEqual(request?.url?.absoluteString, "https://swapi.dev/api/people")
        XCTAssertEqual(request?.httpMethod, "GET")
    }
    
    func testGetPeople() {
        
        let getPeopleURL = URL(string: "https://swapi.dev/api/people")
        URLProtocolMock.testURLs = [getPeopleURL: Data(Fixtures.peopleResponse.utf8)]
        
        //1) When is valid
        URLProtocolMock.response = mocks.validResponse
        let publisher = apiService.getPeople()

        let validTest = evalValidResponseTest(publisher: publisher)
        wait(for: validTest.expectations, timeout: testTimeout)
        validTest.cancellable?.cancel()
        
        //2) When has invalid response
        URLProtocolMock.response = mocks.invalidResponse
        let publisher2 = apiService.getPeople()
        let invalidTest = evalInvalidResponseTest(publisher: publisher2)
        wait(for: invalidTest.expectations, timeout: testTimeout)
        invalidTest.cancellable?.cancel()
        
        //3) When has invalid data and valid response
        URLProtocolMock.testURLs[getPeopleURL] = Data("{{}".utf8)
        URLProtocolMock.response = mocks.validResponse
        
        let publisher3 = apiService.getPeople()
        let invalidTest3 = evalInvalidResponseTest(publisher: publisher3)
        wait(for: invalidTest3.expectations, timeout: testTimeout)
        invalidTest3.cancellable?.cancel()
        
        //4) Network Failure
        URLProtocolMock.response = mocks.validResponse
        URLProtocolMock.error = mocks.networkError
        
        let publisher4 = apiService.getPeople()
        let invalidTest4 = evalInvalidResponseTest(publisher: publisher4)
        wait(for: invalidTest4.expectations, timeout: testTimeout)
        invalidTest4.cancellable?.cancel()
    }
}
