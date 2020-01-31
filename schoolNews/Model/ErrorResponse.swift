//
//  Error.swift
//  schoolNews
//
//  Created by 이유리 on 22/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let code:       String?
    let message:    String?
    
    enum CodingKeys : String, CodingKey {
        case code       = "CODE"
        case message    = "MESSAGE"
    }
    
    init(from decoder: Decoder) throws {
        let values      = try decoder.container(keyedBy: CodingKeys.self)
        code            = try values.decodeIfPresent(String.self, forKey: .code)
        message         = try values.decodeIfPresent(String.self, forKey: .message)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)
    }
}


