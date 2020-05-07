//
//  SubjectResponse.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct SubjectResponse: Codable {
    var id: String
    var name: String
    var code: String
    var version: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name = "Name"
        case code = "Code"
        case version = "__v"
    }
}

/*
 
 {
     "_id": "5e8d213e667a4e006b7c5a01",
     "Name": "ANTH",
     "Code": "ANTH",
     "Term": "2020-Spring",
     "__v": 0
 }
 
 */
