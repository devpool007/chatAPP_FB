//
//  ViewController.swift
//  GameofChats
//
//  Created by Devansh Sharma on 04/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self , action: #selector(handleLogout) )
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleMessage))

        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        

      
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    
    func observeUserMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String : Any]{
                    let message = Message()
                    message.fromID = dictionary["fromId"] as? String
                    message.text = dictionary["text"] as? String
                    message.timeStamp = dictionary["timeStamp"] as? NSNumber
                    message.toID = dictionary["toId"] as? String
                    self.messages.append(message)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        
                        self.messages.sort(by: { (Message1, Message2) -> Bool in
                            return (Message1.timeStamp?.intValue)! > (Message2.timeStamp?.intValue)!
                            
                        })
                    }
                //workaround so that table get reloaded less time and there is no issue of wrong image reloading
                   self.timer?.invalidate()
                    print("we just cancelled our timer")
                   self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                   print("schedule a table reload in 0.1 sec")
                    
                }            })
            
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    
    func handleReloadTable(){
    
        DispatchQueue.main.async {
           print("we reloaded our table view")
            self.tableView.reloadData()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellID")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {return}
        
       let ref = Database.database().reference().child("User").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            guard let dictionary = snapshot.value as? [String : Any] else {
                return
            }
            
          let user = USer()
            user.id = chatPartnerId
            user.key = snapshot.key
            user.name = dictionary["name"] as? String
            user.email = dictionary["email"] as? String
            user.profileImageUrl = dictionary["profileImageUrl"] as? String
        
            self.showChatControllerForUser(user: user)
        })
        
        

        //showChatControllerForUser(user: <#T##USer#>)
    }
    
    func handleMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagescontroller = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserLoggedIn(){
        
        //user not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
           fetchUserAndSetupNavbarTitle()
        }
    }
    
    func fetchUserAndSetupNavbarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else {/*for some reason uid nill so we*/ return}
        Database.database().reference().child("User").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:AnyObject] {
                
                    //self.navigationItem.title = dictionary["name"] as? String
                
                    let user = USer()
                    user.name = dictionary["name"] as? String
                    user.profileImageUrl = dictionary["profileImageUrl"] as? String
                    self.setupNavbar(user: user)
            }
            
        }, withCancel: nil)
        
    }
    
    func setupNavbar(user: USer){
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        //After erasing the messages we call the messages to load again
        observeUserMessages()
    
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //titleView.backgroundColor = UIColor.red
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(container)
        
        //constraints
        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: titleView.centerYAnchor),
            container.centerXAnchor.constraint(equalTo: titleView.centerXAnchor)
            ])
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        container.addSubview(profileImageView)
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCache(urlString: profileImageUrl)
            
        }
        
        //constraints
        NSLayoutConstraint.activate([
            profileImageView.leftAnchor.constraint(equalTo: container.leftAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
            ])
        
        
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        

        //constaraints
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            nameLabel.rightAnchor.constraint(equalTo: container.rightAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 40)
            ])
      
        self.navigationItem.titleView = titleView
        
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatControllerForUser(user : USer){
        
        let chatLog = chatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLog.user = user
        navigationController?.pushViewController(chatLog, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError{
            
            print(logoutError )
        }
        
        
        let Login = LoginController()
        Login.messageController = self
        present(Login, animated: true, completion: nil)
    }
    
    

}


