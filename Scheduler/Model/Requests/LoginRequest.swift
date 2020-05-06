//
//  LoginRequest.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct LoginRequest: Codable {
    var email: String
    var password: String
}

/*
 
 {
     "email": "us",
     "password": "some-password"
 }
 
 */
