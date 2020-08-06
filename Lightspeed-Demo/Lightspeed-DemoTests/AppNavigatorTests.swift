//
//  AppNavigatorTests.swift
//  Lightspeed-DemoTests
//
//  Created by Michael Eid on 7/21/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import XCTest
@testable import Lightspeed_Demo

class AppNavigatorTests: XCTestCase {

    var subject: AppNavigator!
    var window: UIWindow?

    override func setUp() {
        super.setUp()

        Current = Environment()
        window = UIWindow()
        subject = AppNavigator(window: window!)
        window?.makeKeyAndVisible()
    }

    override func tearDown() {
        super.tearDown()
        window?.resignKey()
    }

    func testShowsStartViewOnStart() {
        // When
        subject.start()

        // People list view is displayed
        let navigationController = window?.rootViewController as? UINavigationController
        let peopleListViewController = navigationController?.topViewController as? PeopleListViewController
        XCTAssertNotNil(peopleListViewController, "Not showing start view")
    }

}
