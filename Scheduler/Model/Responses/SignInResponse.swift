//
//  SignInResponse.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct SignInResponse: Codable {
    var email: String
    var token: String
}
