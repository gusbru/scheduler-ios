//
//  File.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct SignInRequest: Codable {
    var name: String
    var email: String
    var password: String
}
