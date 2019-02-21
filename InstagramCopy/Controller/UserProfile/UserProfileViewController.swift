//
//  UserProfileViewController.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/14.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileViewController: UICollectionViewController {

    // MARK: Properties
    var user: User?
    var userToLoadFromSearchVC: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        // background color
        self.collectionView.backgroundColor = .white
        
        // fetch userdata
        if userToLoadFromSearchVC == nil {
            fetchCurrentUserData()
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        
        // set the user in header
        if let user = self.user {
            header.user = user
        } else if let userToLoadFromSearchVC = self.userToLoadFromSearchVC {
            header.user = userToLoadFromSearchVC
            navigationItem.title = userToLoadFromSearchVC.username
        }
        
        // return header
        return header
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }

    // MARK: API
    
    func fetchCurrentUserData() {
        
        guard let currentUid = AUTH.currentUser?.uid else {return}
        
        let docRef = USER_REF.document(currentUid)
        
        docRef.getDocument { (documentSnapshot, error) in
            guard let dictionary = documentSnapshot?.data() as Dictionary<String, AnyObject>? else{ return }
            let user = User(uid: currentUid, dictionary: dictionary)
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }

}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
        
    }
    
}

extension UserProfileViewController: UserProfileHeaderDelegate {
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        
        
        
        print("handleEditFollowTapped called")
        guard let user = header.user else {
            print("cannnot assign user")
            return
        }
        if header.editProfileFollowButton.titleLabel?.text == "Follow" {
            header.editProfileFollowButton.setTitle("Following", for: .normal)
            user.follow()
        } else {
            header.editProfileFollowButton.setTitle("Follow", for: .normal)
            user.unfollow()
        }
    }
    
    
    
    
}
