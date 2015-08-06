//
//  UIViewController+ParseQueries.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UIViewController+ParseQueries.h"
#import "VenueView.h"
#import "EventListView.h"
#import "ConversationView.h"
#import "ProgramView.h"
#import "OverviewView.h"
#import "ProgramForumView.h"
#import "AttendeeDetailView.h"
#import "AttendeeView.h"
#import "ChatView.h"
#import "TimelineView.h"
#import "TimelineDetailView.h"
#import "TimelinePostView.h"
#import "CareerView.h"

@implementation UIViewController (ParseQueries)

#pragma mark - Venue

- (void) getVenue:(id)caller forEvent:(PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Venue"];
    [query whereKey:@"event" equalTo:event];
    [query orderByDescending:@"order"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"venue query success with results: %lu", (unsigned long)[objects count]);
        [caller processData:objects];
    }];
}

#pragma mark - People

- (void)getPeople: (id)caller withSearch: (NSArray *)searchArray forEvent:(PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query includeKey:@"User"];
    [query orderByAscending:@"last_name"];
    [query setLimit:500];
    [query whereKey:@"events" containsAllObjectsInArray:@[event]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    if (searchArray.count >=1)
    {
        [query whereKey:@"words" containsAllObjectsInArray:searchArray];
        NSLog(@"person query search array not empty");
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Person query with search, success with results: %lu", (unsigned long)[objects count]);
        [caller processData:objects];
    }];
}

- (void)getPeople: (id)caller forEvent: (PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query includeKey:@"User"];
    [query orderByAscending:@"last_name"];
    [query setLimit:500];
    [query whereKey:@"events" containsAllObjectsInArray:@[event]];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Person query without search, success with results: %lu, for event: %@", (unsigned long)[objects count], event.objectId);
        [caller processData:objects];
    }];
}

#pragma mark - Timeline

- (void)getPosts: (id)caller forEvent: (PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"event" equalTo:event];
    [query includeKey:@"author"];
    [query setLimit:500];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Post query success: %lu", (unsigned long)[objects count]);
        [caller processData:objects];
    }];
}

- (void)getComments: (id)caller forPost: (PFObject *)post
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"post" equalTo:post];
    [query includeKey:@"author"];
    [query setLimit:500];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Comment query success: %lu", (unsigned long)[objects count]);
        [caller processData:objects];
    }];
}

- (void)sendComment: (id)caller forPost: (PFObject *)post withContent: (NSString *)content withAuthor: (PFUser *)author
{
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"content"] = content;
    comment[@"author"] = author;
    comment[@"post"] = post;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"Successfully published new comment");
            [caller commentPostedCallback];
        }
        else
        {
            NSLog(@"Error posting comment: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)sentPost: (id)caller withAuthor: (PFUser *)author withContent: (NSString *)content withImage: (PFFile *)image forEvent: (PFObject *)event
{
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    post[@"author"] = author;
    post[@"content"] = content;
    post[@"image"] = image;
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"Successfully published new post");
        }
        else
        {
            NSLog(@"Error posting comment: %@", error);
        }
    }];
}

#pragma mark - Chat

- (void)getConversations:(id)caller withUser:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query whereKey:@"participants" containsAllObjectsInArray:@[user]];
    [query includeKey:@"participants"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"conversation query error");
        } else {
            NSLog(@"conversation query success:%lu", (unsigned long)[objects count]);
            [caller processData:objects];
        }
    }];
}

- (void)sendChat:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation
{
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    chat[@"content"] = content;
    chat[@"author"] = user;
    chat[@"conversation"] = conversation;
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new chat uploaded successfully");
            conversation[@"last_time"] = [NSDate date];
            conversation[@"last_msg"] = content;
            [conversation saveInBackground];
            //[caller processChatUploadWithConversation:conversation withContent:content];
        }
        else
        {
            NSLog(@"chat upload error:%@",error);
        }
    }];
}

- (void)sendBroadcast:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation withParticipants:(NSArray *)participants
{
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    chat[@"content"] = content;
    chat[@"author"] = user;
    chat[@"broadcast"] = @1;
    chat[@"conversation"] = conversation;
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new broadcast uploaded successfully, sending push");
            NSString *pushstr = content;
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  pushstr, @"alert",
                                  @"Increment", @"badge",
                                  @"default", @"sound",
                                  nil];
            // Create our Installation query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" containedIn:participants];
            // Send push notification to query
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery]; // Set our Installation query
            [push setData:data];
            [push sendPushInBackground];
        }
        else
        {
            NSLog(@"broadcast upload error:%@",error);
        }
    }];
}

- (void)getChat:(id)caller withConversation:(PFObject *)conversation
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"conversation" equalTo:conversation];
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"author"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"chat query success with # of chats: %ld", (unsigned long)[objects count]);
        [caller processChatList:objects];
    }];
}

- (void)getPrivateChat: (id)caller withUser: (PFUser *)user alongWithSelf: (PFUser *) currentUser
{
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query whereKey:@"is_group" notEqualTo:@1];
    [query includeKey:@"participants"];
    [query whereKey:@"participants" containsAllObjectsInArray:@[user, currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu conversations for these users.", (unsigned long)objects.count);
        //[caller processConversationData:objects];
    }];
}

- (void)getInviteeList: (id)caller withoutUsers:(NSArray *)users
{
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query whereKey:@"chat_status" equalTo:@1];
    [query whereKey:@"debug_status" notEqualTo:@1];
    [query includeKey:@"user"];
    [query whereKey:@"user" notContainedIn:users];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu invitees.(persons)", (unsigned long)objects.count);
        //[caller processInviteeData:objects];
    }];
}

#pragma mark - Program

- (void)getProgram: (id)caller ofType: (int)type withOrder: (int)order forEvent: (PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Talk"];
    [query whereKey:@"event" equalTo:event];
    [query includeKey:@"author"];
    [query includeKey:@"session"];
    [query includeKey:@"location"];
    //type = 0 for talk, =1 for poster, can add others in future if needed
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:type]];
    
    //order = 0 start_time, order = 1 name, can add others in future if needed
    if (order ==0)
    {
        [query orderByDescending:@"start_time"];
    }
    else if (order ==1)
    {
        [query orderByDescending:@"name"];
    }
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu programs for type: %i", (unsigned long)objects.count, type);
        [caller processData:objects];
    }];
}

- (void)getProgram: (id)caller ofType: (int)type withOrder: (int)order withSearch: (NSArray *)searchArray forEvent: (PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Talk"];
    [query whereKey:@"event" equalTo:event];
    [query includeKey:@"author"];
    [query includeKey:@"session"];
    [query includeKey:@"location"];
    //type = 0 for talk, =1 for poster, can add others in future if needed
    [query whereKey:@"type" equalTo:[NSNumber numberWithInt:type]];
    
    //order = 0 start_time, order = 1 name, can add others in future if needed
    if (order ==0)
    {
        [query orderByDescending:@"start_time"];
    }
    else if (order ==1)
    {
        [query orderByDescending:@"name"];
    }
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    if (searchArray.count >=1)
    {
        [query whereKey:@"words" containsAllObjectsInArray:searchArray];
        NSLog(@"program query search array not empty");
    }

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu programs for type: %i with search", (unsigned long)objects.count, type);
        [caller processData:objects];
    }];

}

- (void)getProgram: (id)caller forAuthor: (PFObject *)person forEvent: (PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Talk"];
    [query whereKey:@"event" equalTo:event];
    [query whereKey:@"author" equalTo:person];
    [query orderByDescending:@"name"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu programs for the person %@", (unsigned long)objects.count, person.objectId);
        [caller processData:objects];
    }];
}

#pragma mark - Event

- (void)getEvents: (id)caller
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"admin"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByDescending:@"start_time"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu events", (unsigned long)objects.count);
        [caller processData:objects];
    }];
}

- (void)getEventsFromLocalList: (id)caller
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventIds = [defaults objectForKey:@"eventIds"];
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    [query orderByDescending:@"start_time"];
    [query whereKey:@"objectId" containedIn:eventIds];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu events from local Id list", (unsigned long)objects.count);
        [caller processData:objects];
    }];
}

- (void)getEvent: (id)caller withId: (NSString *)eventId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"admin"];
    [query includeKey:@"attendees"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    [query getObjectInBackgroundWithId:eventId block:^(PFObject *object, NSError *error) {
        NSLog(@"Successfully retrieved single event");
        [caller processEvent:object];
    }];
}

- (void)updateEventList: (id)caller forPerson: (PFObject *) person withList: (NSArray *) events
{
    person[@"events"] = events;
    [person saveInBackground];
}

- (void)getAnnouncements: (id)caller forEvent: (PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Announcement"];
    [query includeKey:@"author"];
    [query orderByAscending:@"createAt"];
    [query whereKey:@"event" equalTo:event];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu announcements for event", (unsigned long)objects.count);
        [caller processData:objects];
    }];
}

#pragma mark - Local

- (void)updateUserPreference: (id)caller forUser: (PFUser *)user
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL mail = [defaults boolForKey:@"mailswitch"];
    BOOL event = [defaults boolForKey:@"eventswitch"];
    BOOL chat = [defaults boolForKey:@"chatswitch"];
    NSString *fn = [defaults stringForKey:@"firstname"];
    NSString *ln = [defaults stringForKey:@"lastname"];
    NSString *inst = [defaults stringForKey:@"institution"];
    NSString *link = [defaults stringForKey:@"link"];
    
    user[@"email_status"] = mail ? @1 : @0;
    user[@"chat_status"] = chat ? @1 : @0;
    user[@"event_status"] = event ? @1 : @0;
    user[@"first_name"] = fn;
    user[@"last_name"] = ln;
    user[@"institution"] = inst;
    user[@"link"] = link;
    
    [user saveInBackground];
}

- (void) removeLocalStorage
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}

- (void)writeUserPreferenceToLocal: (id)caller forUser: (PFUser *)user
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *fn = user[@"first_name"];
    NSString *ln = user[@"last_name"];
    NSString *inst = user[@"institution"];
    NSString *link = user[@"link"];
    BOOL mail = [user[@"email_status"] intValue] == 1 ? YES : NO;
    BOOL event = [user[@"event_status"] intValue] == 1 ? YES : NO;
    BOOL chat = [user[@"chat_status"] intValue] == 1 ? YES : NO;
    [defaults setBool:mail forKey:@"mailswitch"];
    [defaults setBool:event forKey:@"eventswitch"];
    [defaults setBool:chat forKey:@"chatswitch"];
    [defaults setObject:fn forKey:@"firstname"];
    [defaults setObject:ln forKey:@"lastname"];
    [defaults setObject:inst forKey:@"institution"];
    [defaults setObject:link forKey:@"link"];
    [defaults synchronize];
}

#pragma mark - Forum

- (void)getForum: (id)caller forProgram: (PFObject *)program
{
    PFQuery *query = [PFQuery queryWithClassName:@"Forum"];
    [query includeKey:@"author"];
    [query includeKey:@"source"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu forum entries", (unsigned long)objects.count);
        [caller processData:objects];
    }];
}

- (void)postForum: (id)caller forProgram: (PFObject *)program withContent: (NSString *)content withAuthor: (PFUser *)author
{
    PFObject *forum = [PFObject objectWithClassName:@"Forum"];
    forum[@"author"] = author;
    forum[@"content"] = content;
    forum[@"source"] = program;
    [forum saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"Forum post saved successfully");
            [caller postForumSuccessCallback];
        }
        else
        {
            NSLog(@"Forum post error");
        }
    }];
}

#pragma mark - Career

- (void)getCareer: (id)caller
{
    PFQuery *query = [PFQuery queryWithClassName:@"Career"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu career entries", (unsigned long)objects.count);
        [caller processData:objects];
    }];
}

@end
