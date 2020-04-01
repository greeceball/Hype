//
//  User.swift
//  Hype
//
//  Created by Colby Harris on 4/1/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import CloudKit

struct UserConstants {
    static let recordType = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let bioKey = "bio"
    fileprivate static let appleUserRefKey = "appleUserRef"
}

class User {
    
    var username: String
    var bio: String
    var recordID: CKRecord.ID
    var appleUserRef: CKRecord.Reference
    
    /**
        Initialzes a User Object
     
     - Parameters:
        - username: String value for the User's username property
        - bio: String value for the User's bio property, set by default to an empty string
        - recordID: CKRecord.ID value for the User's recordID property, set by default to a uuidString
        - appleUserRef: CKRecord.Reference Value for the User's appleUserRef property
     
     */
    
    init(username: String, bio: String = "", recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserRef: CKRecord.Reference) {
        
        self.username = username
        self.bio = bio
        self.recordID = recordID
        self.appleUserRef = appleUserRef
    }
    
}

extension User {
    
    /**
     Failable Convenience Initializer to init Users from CKRecords
     
     - Parameters:
        - ckRecord: CKRecord containing Key/Value pairs to init a User Object
     
     */
    convenience init?(ckRecord: CKRecord) {
        
        
        guard let username = ckRecord[UserConstants.usernameKey] as? String,
            let bio = ckRecord[UserConstants.bioKey] as? String,
            let appleUserRef = ckRecord[UserConstants.appleUserRefKey] as? CKRecord.Reference
            else { return nil }
        
        self.init(username: username, bio: bio, recordID: ckRecord.recordID, appleUserRef: appleUserRef)
    }
}

extension CKRecord {
    
    /**
     Convenience Initializer to init a CKRecord from a Hype Object
     
     - Parameters:
        - user: The User object to set Key/Value pairs for inside the CKRecord object
     
     */
    
    convenience init(user: User) {
        
        self.init(recordType: UserConstants.recordType, recordID: user.recordID)
        
        setValuesForKeys([
            UserConstants.usernameKey : user.username,
            UserConstants.bioKey : user.bio,
            UserConstants.appleUserRefKey : user.appleUserRef
        ])
    }
}
