//
//  Constants.swift
//  InstagramCopy
//
//  Created by Naoki Muroya on 2019/02/21.
//  Copyright © 2019 Naoki Muroya. All rights reserved.
//

import Firebase

// MARK: - Root References

let AUTH = Auth.auth()
let DB_REF = Firestore.firestore()
let STORAGE_REF = Storage.storage().reference()

// MARK: - Storage References

let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
let STORAGE_MESSAGE_IMAGES_REF = STORAGE_REF.child("message_images")
let STORAGE_MESSAGE_VIDEO_REF = STORAGE_REF.child("video_messages")
let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")

// MARK: - Database References

let USER_REF = DB_REF.collection("users")

let USER_FOLLOWER_REF = DB_REF.collection("user-followers")
let USER_FOLLOWING_REF = DB_REF.collection("user-following")

let POSTS_REF = DB_REF.collection("posts")
let USER_POSTS_REF = DB_REF.collection("user-posts")

let USER_FEED_REF = DB_REF.collection("user-feed")

let USER_LIKES_REF = DB_REF.collection("user-likes")
let POST_LIKES_REF = DB_REF.collection("post-likes")

let COMMENT_REF = DB_REF.collection("comments")

let NOTIFICATIONS_REF = DB_REF.collection("notifications")

let MESSAGES_REF = DB_REF.collection("messages")
let USER_MESSAGES_REF = DB_REF.collection("user-messages")
let USER_MESSAGE_NOTIFICATIONS_REF = DB_REF.collection("user-message-notifications")

let HASHTAG_POST_REF = DB_REF.collection("hashtag-post")

// MARK: - Decoding Values

let LIKE_INT_VALUE = 0
let COMMENT_INT_VALUE = 1
let FOLLOW_INT_VALUE = 2
let COMMENT_MENTION_INT_VALUE = 3
let POST_MENTION_INT_VALUE = 4


