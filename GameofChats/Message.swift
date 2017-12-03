//
//  Message.swift
//  GameofChats
//
//  Created by Devansh Sharma on 02/12/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {

    var fromID : String?
    var text : String?
    var timeStamp : NSNumber?
    var toID : String?
    
    func chatPartnerId() -> String? {
        
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
        
       }
}
