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
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        // background color
        self.collectionView.backgroundColor = .white
        
        // fetch userdata
        if user == nil {
            fetchCurrentUserData()
        }
        
        fetchPosts()
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        
        // set the user in header
        header.user = self.user
        navigationItem.title = user?.username
        
        // return header
        return header
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        
        cell.post = posts[indexPath.row]
        
        return cell
    }

    // MARK: API
    
    func fetchPosts() {
        
        var uid: String!
        
        if let user = self.user {
            uid = user.uid
        } else {
            uid = AUTH.currentUser?.uid
        }
        
        USER_POSTS_REF.document(uid).getDocument { documentSnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let data = documentSnapshot?.data() {
                for postId in data.keys {
                    
                    Firestore.fetchPost(with: postId, completion: { post in
                        
                        self.posts.append(post)
                        
                        self.posts.sort(by: { (post1, post2) -> Bool in
                            return post1.creationDate > post2.creationDate
                        })
                        
                        self.collectionView.reloadData()
                        
                    })
                    
                }
            }
        }
        
    }
    
    
    func fetchCurrentUserData() {
        
        guard let currentUid = AUTH.currentUser?.uid else {return}
        
        let docRef = USER_REF.document(currentUid)
        
        docRef.addSnapshotListener { documentSnapshot, error in
            guard let dictionary = documentSnapshot?.data() as Dictionary<String, AnyObject>? else{ return }
            let user = User(uid: currentUid, dictionary: dictionary)
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView.reloadData()
        }
    }

}

// MARK: UICollectionViewFlowLayout
extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 200)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.viewSinglePost = true
        
        feedVC.post = posts[indexPath.item]
        
        navigationController?.pushViewController(feedVC, animated: true)
        
    }
    
}


// MARK: UserProfileHeader Protocol
extension UserProfileViewController: UserProfileHeaderDelegate {

    func setUserStats(for header: UserProfileHeader) {
        
        guard let uid = header.user?.uid else {return}
        
        var numberOfFollowers: Int!
        var numberOfFollowing: Int!
        
        // get number of followers
        USER_FOLLOWER_REF.document(uid).addSnapshotListener { documentSnapshot, error in
            if let data = documentSnapshot?.data() {
                numberOfFollowers = data.count
            } else {
                numberOfFollowers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followersLabel.attributedText = attributedText
        }
        // get number of following
        USER_FOLLOWING_REF.document(uid).addSnapshotListener { documentSnapshot, error in
            if let data = documentSnapshot?.data() {
                numberOfFollowing = data.count
            } else {
                numberOfFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            
            header.followingLabel.attributedText = attributedText
            
        }
    }
    
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
    
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
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followVC = FollowViewController()
        followVC.viewFollowers = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followVC = FollowViewController()
        followVC.viewFollowing = true
        followVC.uid = user?.uid
        navigationController?.pushViewController(followVC, animated: true)
    }
    
    
}
