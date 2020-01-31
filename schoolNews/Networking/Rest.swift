//
//  Rest.swift
//  schoolNews
//
//  Created by 이유리 on 17/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import RxSwift

typealias Parameters = [String: Any]

class Rest: ReactiveCompatible {
    /// key와 value 값을 쿼리스트링으로 바꿔주는 함수
    static func convertParam(param: [String:Any]) -> String {
        let urlParams = param.flatMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        return urlParams
    }
}

extension Reactive where Base: Rest {
    static func request<T: Codable>(
        api: API,
        parameters: Parameters,
        jsonString: String,
        type: T.Type)
        -> Single<[T]> {
            let params = Rest.convertParam(param: parameters)
            let urlString = api.uri + "?" + params
            /// 주소에 한글이 포함되면 nil을 배출하는 오류 방지
            /// addingPercentEncoding -> 지정된 Set에 없는 모든 문자를 백분율로 인코딩된 문자로 바꾸어 새로운 문자열을 반환해주는 함수
            let encoded  = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            let url = URL(string: encoded!)!
            return Network.responseData(url: url, jsonString: jsonString, type: type)
    }
}
