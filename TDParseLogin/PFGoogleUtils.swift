//
//  PFGoogleUtils.swift
//  TDParseLogin
//
//  Created by Anh Phan Tran on 10/5/17.
//  Copyright © 2017 The Distance. All rights reserved.
//

import Foundation
import Parse
import UIKit
import GoogleSignIn

public class PFGoogleUtils {
    static let authType = "google"
    
    public static func login(with account: GIDGoogleUser, completionHandler: ((PFUser?, TDParseLoginError?) -> Void)?) {
        var authData = [String: String]()
        authData["id_token"] = account.authentication.idToken
        authData["id"] = account.userID
        
        PFUser.logInWithAuthType(inBackground: authType, authData: authData).continue(successBlock: { task -> Void in
            if let user = task.result, task.isCompleted {
                user.email = account.profile.email
                completionHandler?(user, nil)
            } else {
                if let error = task.error {
                    completionHandler?(nil, TDParseLoginError.parseError(error.localizedDescription))
                } else {
                    completionHandler?(nil, TDParseLoginError.unknown)
                }
            }
        })
    }
    
    public static func isLinked(with user: PFUser) -> Bool {
        return user.isLinked(withAuthType: authType)
    }
    
    public static func linkUser(_ user: PFUser, with account: GIDGoogleUser, completionHandler: ((Bool, TDParseLoginError?) -> Void)?) {
        var authData = [String: String]()
        authData["id_token"] = account.authentication.idToken
        authData["id"] = account.userID
        
        user.linkWithAuthType(inBackground: authType, authData: authData).continue(successBlock: { task -> Void in
            if task.isCompleted {
                completionHandler?(true, nil)
            } else {
                if let error = task.error {
                    completionHandler?(false, TDParseLoginError.parseError(error.localizedDescription))
                } else {
                    completionHandler?(false, TDParseLoginError.unknown)
                }
            }
        })
    }
    
    public static func unlinkUser(_ user: PFUser, completionHandler: ((Bool, TDParseLoginError?) -> Void)?) {
        user.unlinkWithAuthType(inBackground: authType).continue(successBlock: { task -> Void in
            if task.isCompleted {
                completionHandler?(true, nil)
            } else {
                if let error = task.error {
                    completionHandler?(false, TDParseLoginError.parseError(error.localizedDescription))
                } else {
                    completionHandler?(false, TDParseLoginError.unknown)
                }
            }
        })
    }
}

class GoogleAuthDelegate: NSObject, PFUserAuthenticationDelegate {
    func restoreAuthentication(withAuthData authData: [String : String]?) -> Bool {
        return true
    }
}
