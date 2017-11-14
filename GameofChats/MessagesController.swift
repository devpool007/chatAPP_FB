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
        
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self , action: #selector(handleLogout) )
        //user not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
    }

    func handleLogout(){
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError{
            
            print(logoutError )
        }
        
        
        let Login = LoginController()
        present(Login, animated: true, completion: nil)
    }
    
    

}

