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
}
