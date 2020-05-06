//
//  ErrorResponse.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-06.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    var Error: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return Error
    }
}

/*
 
 {
     "Error": "invalid user email/password"
 }
 
 */
