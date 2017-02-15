//
//  PFUser+Login.swift
//  TDParseLogin
//
//  Created by Anh Phan Tran on 2/15/17.
//  Copyright © 2017 The Distance. All rights reserved.
//

import Foundation
import Parse

extension TDParseLogin {
    public func changeNew(email: String) {
        if let user = PFUser.current() {
            user.email = email
            user.saveInBackground { succeeded, error in
                if succeeded {
                    self.delegate?.didModify(user)
                } else if error != nil {
                    self.delegate?.failToModify(user, with: .parseError(error!.localizedDescription))
                } else {
                    self.delegate?.failToModify(user, with: .unknown)
                }
            }
        } else {
            self.delegate?.sessionInvalid()
        }
    }
    
    public func changeNew(password: String, currentPassword: String) {
        if let currentUser = PFUser.current() {
            PFUser.logInWithUsername(inBackground: currentUser.username!, password: currentPassword) { (user, error) in
                if error != nil {
                    self.delegate?.failToModify(currentUser, with: .invalidParameters("Current Password"))
                } else {
                    if user != nil {
                        currentUser.password = password
                        currentUser.saveInBackground { succeeded, error in
                            if succeeded {
                                self.delegate?.didModify(currentUser)
                            } else if error != nil {
                                self.delegate?.failToModify(currentUser, with: .parseError(error!.localizedDescription))
                            } else {
                                self.delegate?.failToModify(currentUser, with: .unknown)
                            }
                        }
                    } else {
                        self.delegate?.failToModify(currentUser, with: .unknown)
                    }
                }
            }
        } else {
            self.delegate?.sessionInvalid()
        }
    }
}
