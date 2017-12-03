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

    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self , action: #selector(handleLogout) )
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleMessage))
    }
    
    func handleMessage() {
        let newMessageController = NewMessageController()
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
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatController(){
        
        let chatLog = chatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLog, animated: true)
        
        
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

