//
//  UserError.swift
//  Hype
//
//  Created by Colby Harris on 4/1/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import Foundation

enum UserError: LocalizedError {
    case ckError(Error)
    case noUserLoggedIn
    case couldNotUnwrap
    
    
    var errorDescription: String {
        switch self {
            
        case .ckError(let error):
            return ("Cloudkit returned an error, Error: \(error.localizedDescription)")
        case .noUserLoggedIn:
            return "No user is currently logged in, please visit settings and check your iCloud status"
        case .couldNotUnwrap:
            return "Unable to unwrap the value"
        }
    }
    
}
