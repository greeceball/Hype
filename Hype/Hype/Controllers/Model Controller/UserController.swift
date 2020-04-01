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
    
    
    /**
        Creates a User and saves it to CloudKit
     
     - Parameters:
     - username: Stringvalue to pass into the User init
     - completion: Excaping completion black for the method
     - result: Result found in the completion block with success returning a User and failure returning a UserError
     
     */
    //MARK: - CRUD
    
    func createUserWith(_ username: String, completion: @escaping(Result<User, UserError>) -> Void) {
            // Fetch the AppleId User reference and handle User creation in the closure
        fetchAppleUserReference { (result) in
            switch result {
                
            case .success(let reference):
                // Unwraps the reference
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                // Initializes a newUser object, passing in the username parameter and the unwrapped reference
                let newUser = User(username: username, appleUserRef: reference)
                // creating a CKRecord from a user object using our convenience initializer
                let record = CKRecord(user: newUser)
                // Calls the save function on our publicDB for the record
                self.publicDB.save(record) { (record, error) in
                    // handle the error from the save function
                    if let error = error {
                        completion(.failure(.ckError(error)))
                    }
                    
                    //Unwrapping our record and using it to create a savedUser object
                    guard let record = record, let savedUser = User(ckRecord: record) else { return completion(.failure(.couldNotUnwrap))}
                    // completing with the savedUser
                    completion(.success(savedUser))
                }
            case .failure(let error):
                // prints the error from the fetchAppleUserReference function
                print(error.localizedDescription)
                
            }
        }
        
    }
    
    /**
            Fetches the recordID of the currently logged in AppleID User
     
        - Parameters:
        - completion: Escaping completion block for the method
        - reference: Optional reference for the found AppleID User
     
     */
    
    func fetchAppleUserReference(completion: @escaping(Result<CKRecord.Reference?, UserError>) -> Void) {
        // Calls function to check for recordID info of currently loggen in iCloud User
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            
            // Handle the error
            if let error = error {
                completion(.failure(.ckError(error)))
            }
            
            // unwrapping the recordID and creating a reference object using that recordID
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf) // action is .deleteSelf because if the appleID account doesnt exist anymore the user object should delete itself
                // complete with the reference
                completion(.success(reference))
            }
        }
    }
    
    
    /**
           Fetches the User object that points to the currently logged in AppleID User from the publicDG
    
       - Parameters:
       - completion: Escaping completion block for the method
       - result: Result found in the completion block with success returning a User and failure returning a UserError
    
    */
    
    func fetchUser(completion: @escaping(Result<User, UserError>) -> Void) {
        // Fetch the appleUserRef to pass in for the predicate
        fetchAppleUserReference { (result) in
            switch result {
                
            case .success(let reference):
                
                // unwrap the reference
                guard let reference = reference else { return completion(.failure(.noUserLoggedIn))}
                // Step 3: Creates a predicate that compares the value at the appleUserRef key to the value of the passed in reference.
                let appleUserPredicate = NSPredicate(format: "%k == %@", argumentArray: [UserConstants.appleUserRefKey, reference])// k - represents a key, %@ is the object that needs to match %k
                // Step 2: Creates a query using the predicate to pass into our perform method
                let query = CKQuery(recordType: UserConstants.recordType, predicate: appleUserPredicate)
                // Step 1: Implements the .perform method
                self.publicDB.perform(query, inZoneWith: nil) { (records, error) in
                    // handle our error
                    if let error = error {
                        completion(.failure(.ckError(error)))
                    }
                    // unwrapping the record from the first object in our records array and using to create a user object with our convenience initializer
                    guard let record = records?.first,
                        let foundUser = User(ckRecord: record)
                        else { return completion(.failure(.couldNotUnwrap))}
                    
                    // complete with our found user
                    completion(.success(foundUser))
                    
                }
                
            case .failure(let error):
                // complete with UserError if the fetchAppleUserRef func fails
                completion(.failure(.noUserLoggedIn))
            }
        }
        
    }
    
}
