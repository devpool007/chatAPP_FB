//
//  ChatLogController.swift
//  GameofChats
//
//  Created by Devansh Sharma on 22/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class chatLogController : UICollectionViewController,UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Chat Log"
        collectionView?.backgroundColor = .white
        
        setupInputFields()
    }


    lazy var inputTextField: UITextField = {
    
        let view = UITextField()
        view.placeholder = "Enter Message..."
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.delegate = self
        return view
    
    }()
    
    
func  setupInputFields() {
        let container = UIView()
        container.backgroundColor = .gray
        container.translatesAutoresizingMaskIntoConstraints = false
    
        view.addSubview(container)
    
        //constraints
        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: view.leftAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor),
            container.heightAnchor.constraint(equalToConstant: 50)
            ])
    
    let sendButton = UIButton(type : .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.tintColor = UIColor(red: 42/255, green: 43/255, blue: 54/255, alpha: 1.0)
        container.addSubview(sendButton)
    
        //constraints
        NSLayoutConstraint.activate([
            sendButton.rightAnchor.constraint(equalTo: container.rightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            sendButton.heightAnchor.constraint(equalTo: container.heightAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80)
            ])
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
  
        container.addSubview(inputTextField)
    
        //constraints
        NSLayoutConstraint.activate([
            inputTextField.leftAnchor.constraint(equalTo: container.leftAnchor, constant : 8),
            inputTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            inputTextField.heightAnchor.constraint(equalTo: container.heightAnchor),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor)
            ])
    
    let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 42/255, green: 43/255, blue: 54/255, alpha: 1.0)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(separatorView)
    
        //constraints
        NSLayoutConstraint.activate([
            separatorView.leftAnchor.constraint(equalTo: container.leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: container.rightAnchor),
            separatorView.topAnchor.constraint(equalTo: container.topAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 2)
            ])
}

    func handleSend() {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let values = ["text" : inputTextField.text!]
        childRef.updateChildValues(values)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
}
