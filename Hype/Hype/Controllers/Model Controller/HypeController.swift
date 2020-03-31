//
//  HypeController.swift
//  Hype
//
//  Created by Colby Harris on 3/30/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import CloudKit

class HypeController {
    
    //MARK: - Source of Truth and Shared Instance
    static let shared = HypeController()
    var hypes: [Hype] = []
    
    // gain access to the data base
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //MARK: - CRUD
    
    func saveHype(body: String, completion: @escaping (Bool) -> Void) {
        
        
        let hype = Hype(body: body)
        
        let record = CKRecord(hype: hype)
        
        publicDB.save(record) { (record, error) in
            if let error = error {
                print(error, error.localizedDescription)
                return completion(false)
            }
            
            //record? we get record back as a confirmation that it was successfully saved, then we append the one we get back from the server to the source of truth
            guard let record = record,
                let hype = Hype(ckRecord: record) else { return completion(false) }
            
            self.hypes.insert(hype, at: 0) // adds the hype to the front of the array
            
            //self.hypes.append(hype) // adds the hype to the end of the array
            return completion(true)
        }
    }
    func fetchAllHypes(completion: @escaping (Bool) -> Void) {
        
        let predicate = NSPredicate(value: true) // Predicate is a bool in if statement form: body == "something hype", or timestamp > one week then it grabs all the ones that meet that criterial
        
        let query = CKQuery(recordType: HypeStrings.recordTypeKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            // error handling
            if let error = error {
                print(error, error.localizedDescription)
                return completion(false)
            }
            
            // records?
            guard let records = records else { return completion(false) }
            let hypes: [Hype] = records.compactMap(Hype.init(ckRecord: )) // can use this
            //let hypes2: [Hype] = records.compactMap { Hype(ckRecord: $0) }// or this, they do the same thing.
            
            self.hypes = hypes
            
            return completion(true)
        }
    }
    
    func update(_ hype: Hype, completion: @escaping (Result<Hype?, HypeError>)-> Void) {
        // Declaring a constant called record of type CKRecord that will be created from the hype object that we passed in
        let record = CKRecord(hype: hype)
        
        // Creating an operation that will modify records currently on the database
        let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        //Setting our operation properties
        //Stating that we only want to update the changed keys or values
        operation.savePolicy = .changedKeys
        
        //Stating that this operation is important for the UI
        operation.qualityOfService = .userInteractive
        
        // Setting the completion block for our operation
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            // Handling our error
            if let error = error {
                print(error.localizedDescription + "---> \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            
            // Making sure that we got records back and then turning them into 'Hype' objects
            guard let record = records?.first, let updatedHype = Hype(ckRecord: record) else { completion(.failure(.couldNotUnwrap)); return }
            
            completion(.success(updatedHype))
        }
        // adding this to our publicDB so that it is ran
        publicDB.add(operation)
    }
    func delete(_ hype: Hype, completion: @escaping(Result<Bool, HypeError>) -> Void) {
        
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [hype.recordID])
        
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (records, _, error) in
            if let error = error {
                print(error.localizedDescription + "---> \(error)")
                completion(.failure(.ckError(error)))
                return
            }
            if records?.count == 0 {
                completion(.success(true))
            } else {
                completion(.failure(.unexpectedRecordFound))
            }
        }
        
        publicDB.add(operation)
        
    }
    
    func subscribeForRemoteNotifications(completion: @escaping (Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: HypeStrings.recordTypeKey, predicate: predicate, options: .firesOnRecordCreation)
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.title = "Hype was added."
        notificationInfo.alertBody = "Come check it out."
        notificationInfo.shouldBadge = true
        
        subscription.notificationInfo = notificationInfo
        
        publicDB.save(subscription) { (_, error) in
            if let error = error {
                print(error.localizedDescription + "---> \(error)")
                completion(error)
            }
            completion(nil)
        }
    }
}

