//
//  UIViewController+ParseQueries.h
//  KKNN24
//
//  Created by csjan on 6/2/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UIViewController (ParseQueries)

- (void)getVenue: (id)caller;
- (void)getTalks: (id)caller;
- (void)getTalks: (id)caller forAuthor: (PFObject *)person;
- (void)getPosters: (id)caller;
- (void)getPosters: (id)caller forAuthor: (PFObject *)person;
- (void)getAttachments: (id)caller;
- (void)getAttachments: (id)caller forAuthor: (PFObject *)person;
- (void)getPeople: (id)caller withSearch: (NSMutableArray *)searchArray;
- (void)getPosts: (id)caller;
- (void)getConversations: (id)caller withUser: (PFUser *)user;
- (void)sendChat: (id)caller withAuthor: (PFUser *)user withContent: (NSString *)content withConversation: (PFObject *)conversation;
- (void)getChat: (id)caller withConversation: (PFObject *)conversation;
- (void)getPrivateChat: (id)caller withUser: (PFUser *)user alongWithSelf: (PFUser *) currentUser;

@end
