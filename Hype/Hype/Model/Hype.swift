//
//  Hype.swift
//  Hype
//
//  Created by Colby Harris on 3/30/20.
//  Copyright © 2020 Colby_Harris. All rights reserved.
//

import CloudKit

//MARK: - Constants
struct HypeStrings {
    static let bodyKey = "body"
    static let timeStampKey = "timestamp"
    static let recordTypeKey = "Hype"
}

//MARK: - Model
class Hype {
    let body: String
    let timestamp: Date
    
    init(body: String, timestamp: Date = Date()){
        self.body = body
        self.timestamp = timestamp
    }
}



//Incoming <--- (CKRecord into Hype)

extension Hype {
    
    convenience init?(ckRecord: CKRecord) {
        // get the body and timestamp
        guard let body = ckRecord[HypeStrings.bodyKey] as? String,
            let timestamp = ckRecord[HypeStrings.timeStampKey] as? Date else { return nil }
        
        
        //init
        self.init(body: body, timestamp: timestamp)
    }
}


//Outgoing ---> (Hype into CKRecord)

extension CKRecord {
    
    convenience init(hype: Hype) {
        
        // create CKRecord
        self.init(recordType: HypeStrings.recordTypeKey)
        
        // add properties to it
        self.setValuesForKeys([
            HypeStrings.bodyKey: hype.body,
            HypeStrings.timeStampKey: hype.timestamp])
    
        
//        // the other way to add properties
//        self.setValue(hype.body, forKey: HypeStrings.bodyKey)
//        self.setValue(hype.timestamp, forKey: HypeStrings.timeStampKey)
    }
}



