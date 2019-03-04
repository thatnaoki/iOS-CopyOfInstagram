//
//  UploadPostViewController.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/14.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

import UIKit
import Firebase

class UploadPostViewController: UIViewController, UITextViewDelegate {

    // MARK: Properties
    
    var selectedImage: UIImage?
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure components
        configureViewComponents()
        
        // load image
        loadImage()
        
        // text view delegate
        captionTextView.delegate = self
        
        view.backgroundColor = .white
        
    }
    
    // MARK: UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
    
    // MARK: Handler
    
    func updateUserFeeds(with postId: String) {
        
        // current userId
        guard let currentUid = AUTH.currentUser?.uid else {return}
        
        // database values
        let values = [postId: 1]
        
        USER_FOLLOWER_REF.document(currentUid).getDocument { documentSnapshot, error in
            guard let data = documentSnapshot?.data() else {return}
            // update follower feeds
            for followerUid in data.keys {
                USER_FEED_REF.document(followerUid).setData(values, merge: true)
            }
            // update current user feed
            USER_FEED_REF.document(currentUid).setData(values, merge: true)
        }
        
    }
    
    @objc func handleSharePost() {
        
        // paramaters
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = AUTH.currentUser?.uid else {return}
        
        // image upload data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else {return}
        
        // update storage
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // update storage
        let filename = NSUUID().uuidString
        let ref = STORAGE_REF.child("post_images").child(filename)
        ref.putData(uploadData, metadata: nil) { (metadata, error) in
            
            // handle error
            if let error = error {
                print("failed to uploadimage to storage with error", error.localizedDescription)
                return
            }
            
            // image url
            ref.downloadURL {url, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let url = url else {return}
                
                let urlString = url.absoluteString
                
                // post data
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": urlString,
                              "ownerUid": currentUid] as [String: Any]
                
                // upload information to database
                var ref: DocumentReference? = nil
                
                ref = POSTS_REF.addDocument(data: values, completion: { error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        // update user-post structure
                        guard let documentId = ref?.documentID else {return}
                        USER_POSTS_REF.document(currentUid).setData([documentId : 1], merge: true)
                        // update user-feeds structure
                        self.updateUserFeeds(with: documentId)
                    }
                })
                
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                }
            }
        }
        
    }
    
    
    func configureViewComponents() {
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    }

    func loadImage() {
        
        guard let selectedImage = self.selectedImage else {return}
        
        photoImageView.image = selectedImage
        
    }

}
