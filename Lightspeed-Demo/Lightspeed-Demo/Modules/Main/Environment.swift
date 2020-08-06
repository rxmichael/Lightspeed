//
//  Environment.swift
//  Lightspeed-Demo
//
//  Created by Michael Eid on 7/17/20.
//  Copyright © 2020 Michael Eid. All rights reserved.
//

import Foundation


var Current: Environment!

struct Environment {
    var apiService: SWAPIService = SWAPIService()

    var endpoint: String = "https://swapi.dev/api"
}
