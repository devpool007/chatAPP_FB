//
//  Extensions.swift
//  GameofChats
//
//  Created by Devansh Sharma on 11/11/17.
//  Copyright © 2017 Devansh Sharma. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()


extension UIImageView {

    func loadImageUsingCache(urlString: String) {
        
        
        self.image = nil
        
            //CHECK cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            
            self.image = cachedImage
            return
        }
        
            //otherwise fire of a new download
            let url = URL(string: urlString)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                //download hits an error so lets return out
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    if let downloadedImage = UIImage(data: data!){
                    
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                        self.image = downloadedImage

                    
                    }
                    
                    
                })
                
            }).resume()
        }

    }
    

