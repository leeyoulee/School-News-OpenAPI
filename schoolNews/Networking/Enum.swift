//
//  ParameterEncoding.swift
//  schoolNews
//
//  Created by 이유리 on 17/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
}

public enum Result<Value> {
    case success(Value)
    case nonData(Value)
    case failure(Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .nonData:
            return false
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .nonData(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .nonData:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public enum ErrorCode: Error {
    case responseFailure(code: ResultCode)
}

public enum ResultCode: String {
//    case if_2001 = "INFO-NODATA"
    case if_200 = "INFO-200"
}
