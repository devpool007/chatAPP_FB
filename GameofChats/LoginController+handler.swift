//
//  LoginController+handler.swift
//  GameofChats
//
//  Created by Devansh Sharma on 10/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

extension LoginController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    
    func handleRegister(){
        
        guard let email = emailTextField.text, let pass = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not Valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: pass,completion:  { (user : User?, error) in
            if error != nil{
                
                print(error ?? "Please,Check your internet")
                return
            }
            guard let uid = user?.uid else{
                return
            }
            //successfully authenticated user
            
            let imageNamed = NSUUID().uuidString
            
            let storageReference  = Storage.storage().reference().child("profile_images").child("\(imageNamed).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
           // if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!)
            
                
                 storageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil
                    {
                        
                        print(error)
                        return
                    }
                    
                    if let profileImageUrl =  metadata?.downloadURL()?.absoluteString {
                         let values = ["name" : name,"email" : email, "password" : pass, "profileImageUrl" : profileImageUrl]
                        
                         self.registerUserIntoDatabaseWithUID(uid: uid, values: values)
                    }
                    
                 })
            }
        
           
        })
        
        
    }
    private func registerUserIntoDatabaseWithUID(uid:String, values:[String:Any]){
        
        let ref = Database.database().reference(fromURL: "https://gameofchats-f13b3.firebaseio.com/")
        
        let userReference = ref.child("User").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil{
                print (err!)
                return
            }
            
            //self.messageController?.navigationItem.title = values["name"] as? String
            //self.messageController?.fetchUserAndSetupNavbarTitle()
            let user = USer()
            user.name = values["name"] as? String
            user.profileImageUrl = values["profileImageUrl"] as? String
            self.messageController?.setupNavbar(user: user)
            
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    
    func handleSelectProfileImage(){
    
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    
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
            profileImageView.image = selectedImage
        }

        dismiss(animated: true, completion: nil)

    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
    }
}
