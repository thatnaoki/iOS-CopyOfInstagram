//
//  User.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/14.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

import Firebase

class User {
    
    // attributes
    var username: String!
    var name: String!
    var profileImageURL: String!
    var uid: String!
    var isFollowed = false
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let profileImageURL = dictionary["profileImageUrl"] as? String {
            self.profileImageURL = profileImageURL
        }
        
    }
    
    func follow() {
        
        guard let currentUid = AUTH.currentUser?.uid else {return}
        
        guard let uid = uid else {return}
        
        // set isFollowed to true
        self.isFollowed = true
        
        USER_FOLLOWING_REF.document(currentUid).setData([uid : 1], merge: true)
        
        USER_FOLLOWER_REF.document(uid).setData([currentUid : 1], merge: true)

    }
    
    func unfollow() {
        
        guard let currentUid = AUTH.currentUser?.uid else {return}
        
        guard let uid = uid else {return}
        
        // set isFollowed to true
        self.isFollowed = true
        
        USER_FOLLOWING_REF.document(currentUid).updateData([uid : FieldValue.delete()])
        
        USER_FOLLOWER_REF.document(uid).updateData([currentUid : FieldValue.delete()])
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) -> ()) {
        guard let currentUid = AUTH.currentUser?.uid else {return}
        
        print("checkifuserisfollowed run")
        
        USER_FOLLOWING_REF.document(currentUid).addSnapshotListener { (documentSnapshot, error) in
            
            guard let document = documentSnapshot else {
                print(error?.localizedDescription)
                return
            }
            // そもそも誰かをフォローしているかをチェック
            if let data = document.data() {
                // このユーザーをフォローしているかをチェック
                if let uid = data[self.uid] as? Int {
                    if uid == 1 {
                        self.isFollowed = true
                        print("User is followed")
                        completion(true)
                    }
                } else {
                    self.isFollowed = false
                    print("User is not followed")
                    completion(false)
                }
            } else {
                self.isFollowed = false
                print("User is not followed")
                completion(false)
            }
        }
        
    }
}
