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
}
