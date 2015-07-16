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
- (void)getPeople: (id)caller withSearch: (NSMutableArray *)searchArray forEvent: (PFObject *)event;
- (void)getPeople: (id)caller forEvent: (PFObject *)event;
- (void)getPosts: (id)caller;
- (void)getConversations: (id)caller withUser: (PFUser *)user;
- (void)sendChat: (id)caller withAuthor: (PFUser *)user withContent: (NSString *)content withConversation: (PFObject *)conversation;
- (void)sendBroadcast:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation withParticipants: (NSArray *)participants;
- (void)getChat: (id)caller withConversation: (PFObject *)conversation;
- (void)getPrivateChat: (id)caller withUser: (PFUser *)user alongWithSelf: (PFUser *) currentUser;
- (void)getInviteeList: (id)caller withoutUsers: (NSArray *)users;
- (void)getProgram: (id)caller ofType: (int)type withOrder: (int)order forEvent: (PFObject *)event;
- (void)getProgram: (id)caller forAuthor: (PFObject *)person forEvent: (PFObject *)event;
- (void)getEvents: (id)caller;
- (void)updateEventList: (id)caller forPerson: (PFObject *) person withList: (NSArray *) events;
- (void)updateUserPreference: (id)caller forUser: (PFUser *)user;
@end
