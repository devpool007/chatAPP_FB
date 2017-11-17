//
//  NewMessageController.swift
//  GameofChats
//
//  Created by Devansh Sharma on 09/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellID = "cell"
    var Users = [USer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(goBackToMessageController))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        fetchUser()
    }
    
    
//    func addUser(){
//        Database.database().reference().child("User").observeSingleEvent(of: .childAdded, with: { (<#DataSnapshot#>) in
//            <#code#>
//        }) { (<#Error#>) in
//            <#code#>
//        }
//        
//        
//        
//        
//        
//    }
    
    
    func fetchUser(){
        
        Database.database().reference().child("User").observe(.childAdded, with: { (snapshot) in
            
            guard let data = self.getUserSnapshot(snapshot: snapshot) else {return}
            self.Users.append(data)
            self.tableView.insertRows(at: [IndexPath(row:self.Users.count - 1, section : 0)], with: .left)
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
            
            
        }, withCancel: nil)
        
        Database.database().reference().child("User").observe(.childRemoved, with: { (snapshot) in
            
            var index = self.Users.index(where: {
                return ($0.key == snapshot.key)
            })
            index = index ?? -1
            
            if(index != -1){
                self.Users.remove(at: index!);
                self.tableView.deleteRows(at: [IndexPath(row: index!, section: 0)], with: .right)
                
            }
            
        })
        
    }
    
    
    func goBackToMessageController(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)  as! UserCell
        
        let users = Users[indexPath.row]
        cell.textLabel?.text = users.name
        cell.detailTextLabel?.text = users.email

        
        if let profileImage = users.profileImageUrl {
            
            cell.profileImage.loadImageUsingCache(urlString: profileImage)
            
//            let url = URL(string: profileImage)
//            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
//                
//                //download hits an error so lets return out
//                if error != nil {
//                    print(error!)
//                    return
//                }
//                
//                DispatchQueue.main.async(execute: { () -> Void in
//                    
//                    cell.profileImage.image = UIImage(data: data!)
//
//                    })
//               
//            }).resume()
        }
    
    
        return cell
    
       
    
}

class UserCell: UITableViewCell{
    
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
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier : String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImage)
        NSLayoutConstraint.activate([
            
            profileImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 48),
            profileImage.heightAnchor.constraint(equalToConstant: 48)
            ])
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

}

extension NewMessageController{
    func getUserSnapshot(snapshot:DataSnapshot) -> USer?{
        
        if let dictionary = snapshot.value as? [String:AnyObject] {
            let user = USer()
            user.key = snapshot.key
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
            return user;
            
        }
        return nil
        
    }
    
    
}
