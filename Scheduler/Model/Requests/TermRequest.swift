//
//  TermsRequest.swift
//  Scheduler
//
//  Created by Gustavo Brunetto on 2020-05-07.
//  Copyright © 2020 Gustavo Brunetto. All rights reserved.
//

import Foundation

struct TermsRequest: Codable {
    var id: String
    var termName: String
    var filename: String
    var filepath: String
    var version: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case termName = "Termname"
        case filename = "Filename"
        case filepath = "Filepath"
        case version = "__v"
    }
}

/*
 
 [
     {
         "_id": "5e8d213b667a4e006b7c49f1",
         "Termname": "2020-Spring",
         "Filename": "langara_202001.html",
         "Filepath": "/mnt/backend/data/html/upload_a01d1f5f2094f9f89cd790a487a3d595.html",
         "__v": 0
     }
 ]
 
 */
