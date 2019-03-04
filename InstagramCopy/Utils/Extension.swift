//
//  Extension.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/14.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

import UIKit
import Firebase

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}



extension UIImageView {

    
    
    
}

extension Firestore {
    
    static func fetchUser(with uid: String, completion: @escaping(User) -> ()) {
        
        USER_REF.document(uid).addSnapshotListener({ documentSnapshot, error in
            guard let dictionary = documentSnapshot?.data() as Dictionary<String, AnyObject>? else {return}
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        })
    }
}
