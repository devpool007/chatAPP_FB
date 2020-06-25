//
//  ChatLogController.swift
//  GameofChats
//
//  Created by Devansh Sharma on 22/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class chatLogController : UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
                message.imageURL = dictionary["imageURL"] as? String
                
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
        view.attributedPlaceholder = NSAttributedString(string: "Enter Message...",attributes: [NSForegroundColorAttributeName: UIColor.white])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.delegate = self
        return view
    
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        //collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
//
//        setupKeyboardObsevers()
    }
    
    lazy var inputContainerView: UIView = {
        
            let container = UIView()
            container.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
            container.backgroundColor = UIColor(red: 55/255, green: 155/255, blue: 229/255, alpha: 1.0)
        
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        container.addSubview(uploadImageView)
        //constraints
        NSLayoutConstraint.activate([
           uploadImageView.leftAnchor.constraintEqualToSystemSpacingAfter(container.leftAnchor, multiplier: 1),
            uploadImageView.centerYAnchor.constraintEqualToSystemSpacingBelow(container.centerYAnchor, multiplier: 1),
            uploadImageView.widthAnchor.constraint(equalToConstant: 44),
            uploadImageView.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        
        let sendButton = UIButton(type : .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.tintColor = .white
        container.addSubview(sendButton)
        
        //constraints
        NSLayoutConstraint.activate([
            sendButton.rightAnchor.constraint(equalTo: container.rightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            sendButton.heightAnchor.constraint(equalTo: container.heightAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80)
            ])
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        container.addSubview(self.inputTextField)
        
        //constraints
        NSLayoutConstraint.activate([
            self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant : 8),
            self.inputTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            self.inputTextField.heightAnchor.constraint(equalTo: container.heightAnchor),
            self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor)
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
             return container
        
    }()
    
    func handleUploadTap() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker:UIImage?
        
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }
        else  if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            
            selectedImageFromPicker = originalImage
            
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(image:UIImage){
        
        let imageNamed = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageNamed)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print("Failed to Upload image!", error)
                    return
                }
                if let imageURL = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageURL(imageUrl: imageURL)
                }
                
            })
            
        }

    }
    
    private func sendMessageWithImageURL(imageUrl: String) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toID  = user?.id
        let fromID = Auth.auth().currentUser?.uid
        let timeStamp = Date.timeIntervalSinceReferenceDate
        let values = ["imageURL" : imageUrl, "toId" : toID!, "fromId" : fromID!, "timeStamp" : timeStamp] as [String : Any]
       
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromID!)
            
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId : 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID!)
            recipientUserMessagesRef.updateChildValues([messageId : 1])
        }
        
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView?{
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func setupKeyboardObsevers(){
        
        NotificationCenter.default.addObserver(self, selector:#selector(handleKeyboardWillShow) , name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(handleKeyboardWillHide) , name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillShow(notification: NSNotification){
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        print(keyboardFrame!.height)
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func handleKeyboardWillHide(notification: NSNotification){
         let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
         containerViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
       setupCell(cell: cell, message: message)
        
        //lets modify width of bubbleView somehow???
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            
        }
        return cell
    }
    
    private func setupCell (cell:ChatMessageCell, message : Message){
        
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCache(urlString: profileImageUrl)
        }
        
        if message.fromID == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.bluecolor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }
        else{
            //incoming gray messages
            cell.bubbleView.backgroundColor = ChatMessageCell.graycolor
            cell.textView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
        
        if let messageImageURL = message.imageURL {
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.messageImageView.loadImageUsingCache(urlString: messageImageURL)
            cell.messageImageView.isHidden = false
        }
        else {
            cell.messageImageView.isHidden = true
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        //get estimated height somehow ??
        if let text = messages[indexPath.item].text {
            
            height = estimateFrameForText(text: text).height + 20
            
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
        
    }
    
    private func estimateFrameForText(text : String) -> CGRect{
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor : NSLayoutConstraint?


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
            
            self.inputTextField.text = nil
            
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
