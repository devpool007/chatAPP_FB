//
//  ChatLogController.swift
//  GameofChats
//
//  Created by Devansh Sharma on 22/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class chatLogController : UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout{
    
    var user: USer?{
        
        didSet{
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
           
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String : Any] else {return}
                
                let message = Message()
                //I can use the below statement cause my keys dont match so take care next time cause now I have to waste more lines :(
                //message.setValuesForKeys(dictionary)
                message.fromID = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timeStamp = dictionary["timeStamp"] as? NSNumber
                message.toID = dictionary["toId"] as? String
                
                if message.chatPartnerId() == self.user?.id{
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }

                }
                
                
            })
        
        })
    }

    lazy var inputTextField: UITextField = {
    
        let view = UITextField()
        view.placeholder = "Enter Message..."
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.delegate = self
        return view
    
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupInputFields()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
        //change it to .width sometime and check if same comes?
    }
    
    
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
        let toID  = user?.id
        let fromID = Auth.auth().currentUser?.uid
        let timeStamp = Date.timeIntervalSinceReferenceDate
        let values = ["text" : inputTextField.text!, "toId" : toID!, "fromId" : fromID!, "timeStamp" : timeStamp] as [String : Any]
//        childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromID!)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId : 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID!)
            recipientUserMessagesRef.updateChildValues([messageId : 1])
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
}
