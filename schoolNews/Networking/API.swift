//
//  API.swift
//  schoolNews
//
//  Created by 이유리 on 17/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

struct API {
    let uri: String
    let method: HTTPMethod
    
    init(uri: String, method: HTTPMethod) {
        self.uri = uri
        self.method = method
    }
}

extension API {
    struct SchoolNews {
        static let getSchoolInfo = API(
            uri: "https://open.neis.go.kr/hub/schoolInfo",
            method: .get
        )
        
        static let getSchoolFood = API(
            uri: "https://open.neis.go.kr/hub/mealServiceDietInfo",
            method: .get
        )
    }
}
