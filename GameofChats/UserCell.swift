//
//  UserCell.swift
//  GameofChats
//
//  Created by Devansh Sharma on 02/12/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell{
    
    var message : Message? {
        
        didSet{
            
            setupNameAndProfileImage()
            
            self.detailTextLabel?.text = message?.text
            if let seconds = message?.timeStamp?.doubleValue{
                 let timeStampDate = NSDate(timeIntervalSinceReferenceDate: seconds)
                let date = DateFormatter()
                date.dateFormat = "hh:mm:ss a"
                timeLabel.text = date.string(from: timeStampDate as Date)
            }
           
            
}
    }
    
    private func setupNameAndProfileImage(){
               
        if let Id = message?.chatPartnerId(){
            let ref = Database.database().reference().child("User").child(Id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : Any]
                {
                    self.textLabel?.text = dictionary["name"]  as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String{
                        
                        self.profileImage.loadImageUsingCache(urlString: profileImageUrl)
                        
                    }
                }
                
            })
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y-2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y+2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    
    let profileImage: UIImageView = {
        
        let view = UIImageView()
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    let timeLabel: UILabel = {
    
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.text = ""
        view.font = UIFont(name: "Helvetica", size: 13)
        view.textColor = .gray
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier : String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImage)
        addSubview(timeLabel)
        NSLayoutConstraint.activate([
            
            profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 48),
            profileImage.heightAnchor.constraint(equalToConstant: 48)
            ])
        
        NSLayoutConstraint.activate([
            timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
            timeLabel.widthAnchor.constraint(equalToConstant: 100),
            timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!)
            ])
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

