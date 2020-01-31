//
//  Network.swift
//  schoolNews
//
//  Created by 이유리 on 14/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation
import RxSwift

struct Network {
    
    /// URLSession으로 API와 통신한다
    /// 통신한 데이터를 serializeResponseJSON를 통해 성공, 오류 값으로 나눠가져온다
    /// 가져온 값을 Single 옵저버로 생성해서 방출한다
    static func responseData<T:Codable>(url: URL,
                                        jsonString: String,
                                        type: T.Type) -> Single<[T]> {
        return Single<[T]>.create { single in
            let task: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                // serializeResponseJSON에서 받아온 success, nonData, failure로 선 구분
                let result = serializeResponseJSON(response: response, data: data, error: error, jsonString: jsonString, type: type)
                
                switch result {
                case .success(let response):
                    // success로 받아온 데이터는 검색 결과 -> 모델에 디코드
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: response) else { return }
                    
                    if let data = try? JSONDecoder().decode([T].self, from: jsonData) { // 검색 결과가 있을때는 전달받은 모델에 디코드해줌
                        single(.success(data))
                    } else {
                        single(.error(error!))
                    }
                case .failure(let error):
                    single(.error(error))
                case .nonData(let code):
                    // nonData로 받아온 데이터는 에러 코드 -> 에러 방출
                    if let code = code as? String, code == "INFO-200" {
                        single(.error(ErrorCode.responseFailure(code: ResultCode.if_200)))
                    }
                }
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    /// API에서 받아온 데이터를 원하는 데이터로 serialize해서 방출한다
    static func serializeResponseJSON<T:Codable> (
        response: URLResponse?,
        data: Data?,
        error: Error?,
        jsonString: String,
        type: T.Type)
        -> Result<Any>
    {
        guard let data = data else { return .failure(error!) }
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            if let result = json?["RESULT"] as? [String : Any] {
                if let code = result["CODE"] as? String {
                    return .nonData(code) // 검색한 데이터가 없는 경우 or 기타 Error
                }
            } else {
                if let info = json?[jsonString] as? [[String : Any]] {
                    let row = info[1]
                    let data = row["row"]
                    return .success(data) // 검색한 데이터가 있는 경우
                }
            }
        }
        return .failure(error!) // 통신 Error
    }
    
}

