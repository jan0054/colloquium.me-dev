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

//venue
- (void)getVenue: (id)caller forEvent: (PFObject *)event;

//people
- (void)getPeople: (id)caller withSearch: (NSArray *)searchArray forEvent: (PFObject *)event;
- (void)getPeople: (id)caller forEvent: (PFObject *)event;

//timeline
- (void)getPosts: (id)caller;

//chat
- (void)getConversations: (id)caller withUser: (PFUser *)user;
- (void)sendChat: (id)caller withAuthor: (PFUser *)user withContent: (NSString *)content withConversation: (PFObject *)conversation;
- (void)sendBroadcast:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation withParticipants: (NSArray *)participants;
- (void)getChat: (id)caller withConversation: (PFObject *)conversation;
- (void)getPrivateChat: (id)caller withUser: (PFUser *)user alongWithSelf: (PFUser *) currentUser;
- (void)getInviteeList: (id)caller withoutUsers: (NSArray *)users;

//program
- (void)getProgram: (id)caller ofType: (int)type withOrder: (int)order forEvent: (PFObject *)event;
- (void)getProgram: (id)caller ofType: (int)type withOrder: (int)order withSearch: (NSArray *)searchArray forEvent: (PFObject *)event;
- (void)getProgram: (id)caller forAuthor: (PFObject *)person forEvent: (PFObject *)event;

//event
- (void)getEvents: (id)caller;
- (void)getEventsFromLocalList: (id)caller;
- (void)getEvent: (id)caller withId: (NSString *)eventId;
- (void)updateEventList: (id)caller forPerson: (PFObject *) person withList: (NSArray *) events;

//local
- (void)updateUserPreference: (id)caller forUser: (PFUser *)user;
- (void)removeLocalStorage;
- (void)writeUserPreferenceToLocal: (id)caller forUser: (PFUser *)user;

//forum
- (void)getForum: (id)caller forProgram: (PFObject *)program;
- (void)postForum: (id)caller forProgram: (PFObject *)program withContent: (NSString *)content withAuthor: (PFUser *)author;

@end
