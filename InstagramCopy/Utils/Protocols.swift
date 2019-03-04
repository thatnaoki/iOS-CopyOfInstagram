//
//  Protocols.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/21.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
}

protocol FollowCellDelegate {
    func handleFollowTapped(for cell: FollowCell)
}
