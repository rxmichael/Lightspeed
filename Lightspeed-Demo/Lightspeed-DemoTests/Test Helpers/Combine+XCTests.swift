//
//  Combine+XCTests.swift
//  Lightspeed-DemoTests
//
//  Created by Michael Eid on 7/19/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation
import XCTest
import Combine

typealias Expectation = XCTestExpectation

func evalValidResponseTest<T: Publisher>(publisher: T?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
    XCTAssertNotNil(publisher)
    
    let expectationFinished = Expectation(description: "finished")
    let expectationReceive = Expectation(description: "receiveValue")
    let expectationFailure = Expectation(description: "failure")
    expectationFailure.isInverted = true
    
    let cancellable = publisher?.sink(receiveCompletion: { (completion) in
        switch completion {
        case .failure(let error):
            print("--TEST ERROR--")
            print(error.localizedDescription)
            print("------")
            expectationFailure.fulfill()
        case .finished:
            expectationFinished.fulfill()
        }
    }, receiveValue: { response in
        XCTAssertNotNil(response)
        print(response)
        expectationReceive.fulfill()
    })
    return (expectations: [expectationFinished, expectationReceive, expectationFailure],
            cancellable: cancellable)
}

func evalInvalidResponseTest<T: Publisher>(publisher: T?) -> (expectations: [XCTestExpectation], cancellable: AnyCancellable?) {
    XCTAssertNotNil(publisher)
    
    let expectationFinished = Expectation(description: "Invalid.finished")
    expectationFinished.isInverted = true
    let expectationReceive = Expectation(description: "Invalid.receiveValue")
    expectationReceive.isInverted = true
    let expectationFailure = Expectation(description: "Invalid.failure")
    
    let cancellable = publisher?.sink(receiveCompletion: { (completion) in
        switch completion {
        case .failure(let error):
            print("--TEST FULFILLED--")
            print(error.localizedDescription)
            print("------")
            expectationFailure.fulfill()
        case .finished:
            expectationFinished.fulfill()
        }
    }, receiveValue: { response in
        XCTAssertNotNil(response)
        print(response)
        expectationReceive.fulfill()
    })
     return (expectations: [expectationFinished, expectationReceive, expectationFailure],
                   cancellable: cancellable)
}

extension XCTestCase {

    func evalReceivedResponseValueTest<T: Publisher>(publisher: T?, timeout: TimeInterval) -> T.Output? {
        XCTAssertNotNil(publisher)
        
        let expectationFinished = Expectation(description: "finished")
        let expectationReceive = Expectation(description: "receiveValue")
        let expectationFailure = Expectation(description: "failure")
        expectationFailure.isInverted = true
        
        var responseValue: T.Output?
        
        let cancellable = publisher?.sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                XCTFail("evalReceivedResponseTest should always succeed. \(error.localizedDescription)")
                expectationFailure.fulfill()
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            responseValue = response
            expectationReceive.fulfill()
        })
        
        let expectations = [expectationFinished, expectationReceive, expectationFailure]
        wait(for: expectations, timeout: timeout)
        cancellable?.cancel()

        return responseValue
    }
    
    func evalReceivedResponseErrorTest<T: Publisher>(publisher: T?, timeout: TimeInterval) -> Error? {
        XCTAssertNotNil(publisher)
        
        let expectationFinished = Expectation(description: "Invalid.finished")
        expectationFinished.isInverted = true
        let expectationReceive = Expectation(description: "Invalid.receiveValue")
        expectationReceive.isInverted = true
        let expectationFailure = Expectation(description: "Invalid.failure")

        var receivedError: Error?
        
        let cancellable = publisher?.sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                receivedError = error
                expectationFailure.fulfill()
            case .finished:
                expectationFinished.fulfill()
            }
        }, receiveValue: { response in
            XCTFail("evalReceivedResponseErrorTest should not return a value")
            expectationReceive.fulfill()
        })
        
        let expectations = [expectationFinished, expectationReceive, expectationFailure]
        wait(for: expectations, timeout: timeout)
        cancellable?.cancel()

        return receivedError
    }
}
