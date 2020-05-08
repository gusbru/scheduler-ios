//
//  ListResponse.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-08.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct ListResponse: Codable {
    var id: String
    var subject: String
    var courseNumber: String
    var numberOfCredits: String
    var courseTitle: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case subject = "Subj"
        case courseNumber = "Crse"
        case numberOfCredits = "Cred"
        case courseTitle = "Title"
    }
}

/*
 
 {
     "_id": "5e8e639f667a4e006b7c6380",
     "Subj": "CPSC",
     "Crse": "1030",
     "Cred": "3.00",
     "Title": "Web Development I"
 }
 
 */
