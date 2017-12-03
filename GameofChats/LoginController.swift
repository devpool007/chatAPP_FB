//
//  LoginController.swift
//  GameofChats
//
//  Created by Devansh Sharma on 06/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    var messageController : MessagesController?
    
    var containerHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor : NSLayoutConstraint?
    var emailTextFieldHeightAnchor : NSLayoutConstraint?
    var passwordTextFieldHeightAnchor : NSLayoutConstraint?
    var separatorHeight : NSLayoutConstraint?
    
    let container:UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
        
    }()
    
    let loginRegisterButton: UIButton = {
        
        let view = UIButton(type: .system)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 200/255, green: 56/255, blue: 48/255, alpha: 1.0)
        view.setTitle("Register", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        view.layer.cornerRadius = 5
        view.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return view
    }()
    
    let loginRegisterSegment: UISegmentedControl = {
    
        let view = UISegmentedControl(items: ["Login","Register"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .white
        view.selectedSegmentIndex = 1
        view.addTarget(self, action: #selector (segmentChange), for: .valueChanged)
        return view
    }()
    
    func segmentChange(){
        let title = loginRegisterSegment.titleForSegment(at: loginRegisterSegment.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
       //change height of container but how??
        
        containerHeightAnchor?.constant = loginRegisterSegment.selectedSegmentIndex == 0 ?100: 150
        
        //change height of nameTextField
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier:loginRegisterSegment.selectedSegmentIndex == 0 ?0: 1/3)
        nameTextField.placeholder = loginRegisterSegment.selectedSegmentIndex == 0 ?"": "Name"
        nameTextFieldHeightAnchor?.isActive = true
        
        //change height of emailtextField
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier:loginRegisterSegment.selectedSegmentIndex == 0 ?1/2: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        //change height of passwordTextField
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier:loginRegisterSegment.selectedSegmentIndex == 0 ?1/2: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        separatorHeight?.isActive = loginRegisterSegment.selectedSegmentIndex == 0 ?false:true
        
    }
    
    
    func handleLoginRegister(){
        
        if loginRegisterSegment.selectedSegmentIndex == 0 {
            handleLogin()
        }
        
        else{
        handleRegister()
        }
    }
    
    
    func handleLogin(){
        
        guard let email = emailTextField.text, let pass = passwordTextField.text else {
            print("Form is not Valid")
            return
        }

        Auth.auth().signIn(withEmail: email,password : pass) { (user, error) in
            if error != nil {
                print(error ?? "Oops U are not registered")
                return
            }
            
            //successfully logged in
            self.messageController?.fetchUserAndSetupNavbarTitle()
            
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
        
    
    let nameTextField:UITextField = {
    
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Name"
        return view
        
    }()
    
    let nameSeparator1:UIView = {
    
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField:UITextField = {
        
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Email"
        view.keyboardType = UIKeyboardType.emailAddress
        
        return view
        
    }()
    
    let nameSeparator2:UIView = {
        
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let passwordTextField:UITextField = {
        
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Password"
        view.isSecureTextEntry = true
        return view
        
    }()
   
    lazy var profileImageView:UIImageView = {
        
        let view = UIImageView()
        view.image = UIImage(named: "wolfy")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        view.isUserInteractionEnabled = true
        return view

    }()

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 160/255, green: 56/255, blue: 48/255, alpha: 1.0)
        setupViews()
           }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
extension LoginController{
    //x , y , height and width the simple rule for better constraints
    func setupViews(){
        view.addSubview(loginRegisterSegment)
        view.addSubview(profileImageView)
        view.addSubview(container)
        view.addSubview(loginRegisterButton)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nameSeparator1)
        view.addSubview(nameSeparator2)
        
        
        
        
        NSLayoutConstraint.activate([
            loginRegisterSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterSegment.bottomAnchor.constraint(equalTo: container.topAnchor, constant: -12),
            loginRegisterSegment.widthAnchor.constraint(equalTo: container.widthAnchor),
            loginRegisterSegment.heightAnchor.constraint(equalToConstant: 36)
            ])
                
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegment.topAnchor, constant: -36),
            profileImageView.widthAnchor.constraint(equalToConstant: 200),
            profileImageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24),
        ])
        //For Login Segment control
        containerHeightAnchor = container.heightAnchor.constraint(equalToConstant: 150)
        containerHeightAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 12),
            loginRegisterButton.widthAnchor.constraint(equalTo: container.widthAnchor),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        
        NSLayoutConstraint.activate([
           nameTextField.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 12),
           nameTextField.topAnchor.constraint(equalTo: container.topAnchor),
           nameTextField.widthAnchor.constraint(equalTo: container.widthAnchor),
          
            ])
        //For Login Segment control
        nameTextFieldHeightAnchor =  nameTextField.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            nameSeparator1.leftAnchor.constraint(equalTo: container.leftAnchor),
            nameSeparator1.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeparator1.widthAnchor.constraint(equalTo: container.widthAnchor),
            ])
        separatorHeight = nameSeparator1.heightAnchor.constraint(equalToConstant: 1)
        separatorHeight?.isActive = true
        
        NSLayoutConstraint.activate([
            emailTextField.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 12),
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            emailTextField.widthAnchor.constraint(equalTo: container.widthAnchor),
            ])
         //For Login Segment control
            emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/3)
            emailTextFieldHeightAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            nameSeparator2.leftAnchor.constraint(equalTo: container.leftAnchor),
            nameSeparator2.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            nameSeparator2.widthAnchor.constraint(equalTo: container.widthAnchor),
            nameSeparator2.heightAnchor.constraint(equalToConstant: 1)
            
            ])
        
        NSLayoutConstraint.activate([
            passwordTextField.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 12),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            passwordTextField.widthAnchor.constraint(equalTo: container.widthAnchor),
            ])
         //For Login Segment control
            passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1/3)
            passwordTextFieldHeightAnchor?.isActive = true
    }
    
    
    
    
    
    
}
 
