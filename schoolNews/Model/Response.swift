//
//  Response.swift
//  schoolNews
//
//  Created by 이유리 on 22/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct Response<Type: Codable> : Codable {
    let results: [Type]
    
    enum CodingKeys : String, CodingKey {
        case row = "row"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        results = try values.decode([Type].self, forKey: .row)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(results, forKey: .row)
    }
}


