//
//  ParseLoginError.swift
//  TDParseLogin
//
//  Created by Anh Phan Tran on 2/15/17.
//  Copyright © 2017 The Distance. All rights reserved.
//

import Foundation

public enum TDParseLoginError: Error {
    case accessDenied
    case facebookLoginCancelled
    case facebookLoginFailed
    case twitterLoginFailed
    case twitterLoginCancelled
    case googleLoginFailed
    case googleLoginCancelled
    case wrongCredentials
    case invalidParameters(String)
    case parseError(String)
    case unknown
    
    public var failureReason: String {
        switch self {
        case .accessDenied:
            return NSLocalizedString("Access Denied", comment: "")
        case .facebookLoginFailed:
            return NSLocalizedString("Facebook Login Failed", comment: "")
        case .facebookLoginCancelled:
            return NSLocalizedString("Facebook Login Canceled", comment: "")
        case .twitterLoginFailed:
            return NSLocalizedString("Twitter Login Failed", comment: "")
        case .twitterLoginCancelled:
            return NSLocalizedString("Twitter Login Canceled", comment: "")
        case .googleLoginFailed:
            return NSLocalizedString("Google Login Failed", comment: "")
        case .googleLoginCancelled:
            return NSLocalizedString("Google Login Canceled", comment: "")
        case .wrongCredentials:
            return NSLocalizedString("Wrong Credential", comment: "")
        case .invalidParameters(let details):
            return NSLocalizedString("Some Parameters Are Invalid :\n\(details)", comment: "")
        case .parseError(let details):
            return NSLocalizedString("\(details)", comment: "")
        case .unknown:
            return NSLocalizedString("Unknown Error", comment: "")
        }
    }
}
