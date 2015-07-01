//
//  UIViewController+ParseQueries.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UIViewController (ParseQueries)
- (void)getVenue: (id)caller forEvent: (PFObject *)event;
- (void)getTalks: (id)caller;
- (void)getPeople: (id)caller withSearch: (NSMutableArray *)searchArray;
- (void)getPosts: (id)caller;
- (void)getConversations: (id)caller withUser: (PFUser *)user;
- (void)sendChat: (id)caller withAuthor: (PFUser *)user withContent: (NSString *)content withConversation: (PFObject *)conversation;
- (void)sendBroadcast:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation withParticipants: (NSArray *)participants;
- (void)getChat: (id)caller withConversation: (PFObject *)conversation;
- (void)getPrivateChat: (id)caller withUser: (PFUser *)user alongWithSelf: (PFUser *) currentUser;
- (void)getInviteeList: (id)caller withoutUsers: (NSArray *)users;
- (void)getProgram: (id)caller ofType: (int)type forAuthor: (PFObject *)person withOrdering: (int)order forEvent: (PFObject *)event;

@end
