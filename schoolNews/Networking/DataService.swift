//
//  DataService.swift
//  schoolNews
//
//  Created by 이유리 on 17/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import RxSwift


struct DataService {
    struct SchoolNews {
        
        // School 조회
        static func schoolGet(schoolName: String) -> Single<[School]> {
            var parameters: Parameters = [:]
            require(&parameters, key: "KEY", value: "496305ea8af744c7ab2f3ff184078da8")
            require(&parameters, key: "Type", value: "json")
            require(&parameters, key: "pIndex", value: 1)
            require(&parameters, key: "pSize", value: 100)
            require(&parameters, key: "SCHUL_NM", value: schoolName)
            
            return Rest.rx.request(
                api: API.SchoolNews.getSchoolInfo,
                parameters: parameters,
                jsonString: "schoolInfo",
                type: School.self
                )
        }
        
        // SchoolFood 조회
        static func schoolFoodGet(educationCode: String, schoolCode: String, startDate: String, endDate: String) -> Single<[SchoolFood]> {
            var parameters: Parameters = [:]
            require(&parameters, key: "KEY", value: "496305ea8af744c7ab2f3ff184078da8")
            require(&parameters, key: "Type", value: "json")
            require(&parameters, key: "pIndex", value: 1)
            require(&parameters, key: "pSize", value: 100)
            require(&parameters, key: "ATPT_OFCDC_SC_CODE", value: educationCode)
            require(&parameters, key: "SD_SCHUL_CODE", value: schoolCode)
            require(&parameters, key: "MLSV_FROM_YMD", value: startDate)
            require(&parameters, key: "MLSV_TO_YMD", value: endDate)
            
            return Rest.rx.request(
                api: API.SchoolNews.getSchoolFood,
                parameters: parameters,
                jsonString: "mealServiceDietInfo",
                type: SchoolFood.self
            )
        }
    }
}

func require<T>(
    _ parameters: inout Parameters,
    key: String,
    value: T) {
    if let value = value as? String {
        parameters[key] = value.truncated()
    } else {
        parameters[key] = value
    }
}

extension String {
    func truncated() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


