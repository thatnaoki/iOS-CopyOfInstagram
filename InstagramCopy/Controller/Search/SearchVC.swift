//
//  SearchViewController.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/14.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchViewController: UITableViewController {
    
    // MARK: Properties
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // register cell class
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // sepatator insets
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        configureNavController()
        
        // fetch users
        fetchUsers()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        cell.user = users[indexPath.row]
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        // create instance of user profile vc
        let userProfileVC = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        // passes user from searchVC to userProfileVC
        userProfileVC.user = user
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true)
        
    }
    
    // MARK: Handlers
    func configureNavController() {
        navigationItem.title = "Explore"
        
    }
    
    // MARK: API
    func fetchUsers() {
        USER_REF.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            for document in snapshot!.documents {
                
                print(document.data())
                let uid = document.documentID
                
                Firestore.fetchUser(with: uid, completion: { user in
                    self.users.append(user)
                    self.tableView.reloadData()
                })
                
            }
        }
    }


}
