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
    var imageURL : String?
    var imageWidth : NSNumber?
    var imageHeight : NSNumber?
    
    func chatPartnerId() -> String?
        {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID
    }
    
//    init(dictionary :[String : Any]) {
//        super.init()
//        fromID = dictionary["fromId"] as? String
//        text = dictionary["text"] as? String
//        timeStamp = dictionary["timeStamp"] as? NSNumber
//        toID = dictionary["toId"] as? String
//        imageURL = dictionary["imageURL"] as? String
//        imageWidth = dictionary["imageWidth"] as? NSNumber
//        imageHeight = dictionary["imageHeight"] as? NSNumber
//    }
    
}
