//
//  UserController.swift
//  Hype
//
//  Created by Colby Harris on 4/1/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import CloudKit

class UserController {
    
    static let sharedInstance = UserController()
    
    var currentUser: User?
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - CRUD
    
    func createUserWith(_ username: String, completion: @escaping(Result<User, UserError>) -> Void) {
        
        fetchAppleUserReference { (result) in
            switch result {
                
            case .success(let reference):
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                
                let newUser = User(username: username, appleUserRef: reference)
                
                let record = CKRecord(user: newUser)
                
                self.publicDB.save(record) { (record, error) in
                    if let error = error {
                        completion(.failure(.ckError(error)))
                    }
                    guard let record = record, let savedUser = User(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
                    
                    completion(.success(savedUser))
                }
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
        
    }
    
    func fetchAppleUserReference(completion: @escaping(Result<CKRecord.Reference?, UserError>) -> Void) {
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
            
                completion(.success(reference))
            }
        }
    }
}
