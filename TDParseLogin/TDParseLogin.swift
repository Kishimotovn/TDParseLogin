//
//  PFUser+SocialLogin.swift
//  TDParseLogin
//
//  Created by Anh Phan Tran on 2/15/17.
//  Copyright © 2017 The Distance. All rights reserved.
//

import Foundation
import Parse
import ParseFacebookUtilsV4
import ParseTwitterUtils
import GoogleSignIn

public protocol TDParseLoginDelegate {
    func willSignIn()
    func prepare(newUser user: PFUser) -> TDParseLoginError?
    func didSignIn(with user: PFUser)
    func failedToSignIn(with error: TDParseLoginError)
    func didModify(_ user: PFUser)
    func failToModify(_ user: PFUser, with error: TDParseLoginError)
    func sessionInvalid()
}

extension TDParseLoginDelegate {
    func willSignIn() { }
    func prepare(newUser user: PFUser) -> TDParseLoginError? { return nil }
    func didSignIn(with user: PFUser) { }
    func failedToSignIn(with error: TDParseLoginError) { }
    func didModify(_ user: PFUser) {}
    func failToModify(_ user: PFUser, with error: TDParseLoginError) {}
    func sessionInvalid() {}
}

public class TDParseLogin: NSObject {
    public static let shared = TDParseLogin()
    
    private override init() { }
    
    var googleSignInUIDelegate: GIDSignInUIDelegate?
    var delegate: TDParseLoginDelegate?
    var googleCloudFuncName = "accessGoogleUser"
    
    public func loginWithGoogle() {
        GIDSignIn.sharedInstance().uiDelegate = self.googleSignInUIDelegate
        GIDSignIn.sharedInstance().delegate = self
        self.delegate?.willSignIn()
        GIDSignIn.sharedInstance().signIn()
    }
    
    // To get the email from twitter account, you need to change settings inside your twitter app:
    
    // Go to https://support.twitter.com/forms/platform Select "I need access to special permissions"
    //    
    // Enter Application Name and ID. These can be obtained via https://apps.twitter.com/ -- the application ID is the numeric part in the browser's address bar after you click your app.
    //
    // Permissions Request: "Email address" Submit & wait for response
    //    
    // After your request is granted, an addition permission setting is added in your twitter app's "Permission" section. Go to "Additional Permissions" and just tick the checkbox for "Request email addresses from users".
    public func loginWithTwitter() {
        PFTwitterUtils.logIn { user, error in
            if let user = user {
                if user.isNew {
                    if !PFTwitterUtils.isLinked(with: user) {
                        PFTwitterUtils.linkUser(user) { succeeded, error in
                            if succeeded {
                                let prepareError = self.delegate?.prepare(newUser: user)
                                if prepareError != nil {
                                    self.delegate?.failedToSignIn(with: prepareError!)
                                } else {
                                    self.delegate?.didSignIn(with: user)
                                }
                            } else {
                                if error != nil {
                                    self.delegate?.failedToSignIn(with: .parseError(error!.localizedDescription))
                                } else {
                                    self.delegate?.failedToSignIn(with: .unknown)
                                }
                            }
                        }
                    } else {
                        let prepareError = self.delegate?.prepare(newUser: user)
                        if prepareError != nil {
                            self.delegate?.failedToSignIn(with: prepareError!)
                        } else {
                            self.delegate?.didSignIn(with: user)
                        }
                    }
                } else {
                    self.delegate?.didSignIn(with: user)
                }
            } else {
                if error != nil {
                    self.delegate?.failedToSignIn(with:.twitterLoginFailed)
                } else {
                    self.delegate?.failedToSignIn(with:.twitterLoginCancelled)
                }
            }
        }
    }
    
    public func loginWithFacebook() {
        PFFacebookUtils.logInInBackground(withReadPermissions: ["email", "public_profile"]) { (user: PFUser?, error: Error?) -> Void in
            if let user = user {
                if user.isNew {
                    if !PFFacebookUtils.isLinked(with: user) {
                        PFFacebookUtils.linkUser(inBackground: user, withReadPermissions: ["email", "public_profile"]) { succeeded, error in
                            if succeeded {
                                let prepareError = self.delegate?.prepare(newUser: user)
                                if prepareError != nil {
                                    self.delegate?.failedToSignIn(with: prepareError!)
                                } else {
                                    self.delegate?.didSignIn(with: user)
                                }
                            } else {
                                if error != nil {
                                    self.delegate?.failedToSignIn(with: .parseError(error!.localizedDescription))
                                } else {
                                    self.delegate?.failedToSignIn(with: .unknown)
                                }
                            }
                        }
                    } else {
                        let prepareError = self.delegate?.prepare(newUser: user)
                        if prepareError != nil {
                            self.delegate?.failedToSignIn(with: prepareError!)
                        } else {
                            self.delegate?.didSignIn(with: user)
                        }
                    }
                } else {
                    self.delegate?.didSignIn(with: user)
                }
            } else {
                if error != nil {
                    self.delegate?.failedToSignIn(with:.twitterLoginFailed)
                } else {
                    self.delegate?.failedToSignIn(with:.twitterLoginCancelled)
                }
            }
        }
    }
    
    fileprivate func loginWithGoogle(withUser user: GIDGoogleUser, completionHandler: ((PFUser?, TDParseLoginError?) -> Void)?) {
        PFCloud.callFunction(inBackground: self.googleCloudFuncName, withParameters: ["accessToken": user.authentication.accessToken]) { data, error in
            if error != nil {
                completionHandler?(nil, .parseError(error!.localizedDescription))
            } else {
                if let sessionToken = data as? String {
                    PFUser.become(inBackground: sessionToken) { pfuser, error in
                        if pfuser != nil {
                            if pfuser!.email == nil {
                                pfuser!.email = user.profile.email
                                if let prepareError = self.delegate?.prepare(newUser: pfuser!) {
                                    completionHandler?(nil, prepareError)
                                }
                                do {
                                    try pfuser!.save()
                                } catch let error {
                                    completionHandler?(nil, .parseError(error.localizedDescription))
                                }
                            }
                            completionHandler?(pfuser!, nil)
                        } else {
                            completionHandler?(nil, .googleLoginFailed)
                        }
                    }
                } else {
                    completionHandler?(nil, .googleLoginFailed)
                }
            }
        }
    }
}

extension TDParseLogin: GIDSignInDelegate {
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            self.loginWithGoogle(withUser: user) { user, error in
                if error != nil {
                    self.delegate?.failedToSignIn(with: error!)
                } else {
                    self.delegate?.didSignIn(with: user!)
                }
            }
        } else {
            self.delegate?.failedToSignIn(with: .googleLoginFailed)
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("signed out")
    }
}
