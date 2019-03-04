//
//  FollowVC.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/27.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifer = "FollowCell"

class FollowViewController: UITableViewController, FollowCellDelegate {
    
    // MARK: properties
    var viewFollowers = false
    var viewFollowing = false
    var uid: String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifer)
    
        // configure nav controller
        if viewFollowers {
            navigationItem.title = "Followers"
        } else {
            navigationItem.title = "Following"
        }
        
        // clear separator lines
        tableView.separatorColor = .clear
        
        // fetch users
        fetchUsers()
    }
    
    // MARK: UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! FollowCell
        
        cell.user = users[indexPath.row]
        
        cell.delegate = self
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    // MARK: FollowCellDelegate Protocol
    func handleFollowTapped(for cell: FollowCell) {
        
        guard let user = cell.user else {return}
        
        if user.isFollowed {
            user.unfollow()
            
            // configure follow button for non followed user
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        } else {
            user.follow()
            
            // configure follow button for followed user
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.backgroundColor = .white
        }
        
    }
    
    func fetchUsers() {
        
        guard let uid = self.uid else {return}
        var ref: CollectionReference!
        
        if viewFollowers {
            // fetch followers
            ref = USER_FOLLOWER_REF
        } else {
            // fetch following users
            ref = USER_FOLLOWING_REF
        }
        
        ref.document(uid).getDocument { documentSnapshot, error in
            
            if let data = documentSnapshot?.data() {
                for uid in data.keys {
                    
                    Firestore.fetchUser(with: uid, completion: { user in
                        self.users.append(user)
                        self.tableView.reloadData()
                    })
                }
            }
        }
    }
    
    
    
}
