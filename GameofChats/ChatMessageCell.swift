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
        return view
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        //backgroundColor = .red
        
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.rightAnchor.constraint(equalTo: self.rightAnchor),
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textView.heightAnchor.constraint(equalTo: self.heightAnchor),
            textView.widthAnchor.constraint(equalToConstant: 200)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
