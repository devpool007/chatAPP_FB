//
//  ChatMessageCellTableViewCell.swift
//  GameofChats
//
//  Created by Devansh Sharma on 03/12/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {

    let textView : UITextView = {
    
        let view = UITextView()
        view.text = "Everyday we stray away from God"
        view.font = UIFont(name: "Helvetica", size: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.textColor = .white
        return view
    }()
   
    let bubbleView : UIView = {
     
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 55/255, green: 155/255, blue: 229/255, alpha: 1.0)
        view.layer.cornerRadius = 16
        return view
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .red
        
        addSubview(bubbleView)
        addSubview(textView)
        NSLayoutConstraint.activate([
            bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor,constant:-8),
            bubbleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor),
            ])

        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor,constant: 8),
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor),
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor)
            ])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
