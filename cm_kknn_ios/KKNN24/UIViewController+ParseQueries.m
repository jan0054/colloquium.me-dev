//
//  UIViewController+ParseQueries.m
//  KKNN24
//
//  Created by csjan on 6/2/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UIViewController+ParseQueries.h"
#import "TravelTabViewController.h"
#import "PeopleTabViewController.h"
#import "ConversationListViewController.h"
#import "PersonDetailViewController.h"
#import "ChatViewController.h"

@implementation UIViewController (ParseQueries)

- (void) getVenue:(id)caller {
    PFQuery *query = [PFQuery queryWithClassName:@"Venue"];
    [query orderByDescending:@"order"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"venue query success: %lu", (unsigned long)[objects count]);
        [caller processData:objects];
    }];
}

- (void)getTalks: (id)caller{
    
}
- (void)getPosters: (id)caller{
    
}
- (void)getAttachments: (id)caller{
    
}
- (void)getPeople: (id)caller withSearch: (NSMutableArray *)searchArray {
    PFQuery *personquery = [PFQuery queryWithClassName:@"Person"];
    [personquery orderByAscending:@"last_name"];
    [personquery setLimit:500];
    personquery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    personquery.maxCacheAge = 86400;
    if (searchArray.count >=1)
    {
        [personquery whereKey:@"words" containsAllObjectsInArray:searchArray];
        NSLog(@"person query did do search");
    }
    [personquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"person query success: %lu", (unsigned long)[objects count]);
        [caller processData:objects];
    }];
}
- (void)getPosts: (id)caller{
    
}

- (void)getConversations:(id)caller withUser:(PFUser *)user {
    PFRelation *relation = [user relationForKey:@"conversation"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"conversation query error");
        } else {
            [caller processData:objects];
        }
    }];
}

- (void)getTalks: (id)caller forAuthor: (PFObject *)person {
    PFQuery *query = [PFQuery queryWithClassName:@"Talk"];
    [query whereKey:@"author" equalTo:person];
    [query orderByDescending:@"start_time"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu talks for the person.", (unsigned long)objects.count);
        [caller processTalkData:objects];
    }];
}

- (void)getPosters: (id)caller forAuthor: (PFObject *)person {
    PFQuery *query = [PFQuery queryWithClassName:@"Poster"];
    [query whereKey:@"author" equalTo:person];
    [query orderByDescending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu posters for the person.", (unsigned long)objects.count);
        [caller processPosterData:objects];
    }];
}

- (void)getAttachments: (id)caller forAuthor: (PFObject *)person {
    PFQuery *query = [PFQuery queryWithClassName:@"Attachment"];
    [query whereKey:@"author" equalTo:person];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu talks for the person.", (unsigned long)objects.count);
        [caller processAttachmentData:objects];
    }];
}

- (void)sendChat:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation {
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
            [caller processChatUploadWithConversation:conversation withContent:content];
        }
        else
        {
            NSLog(@"chat push error:%@",error);
        }
    }];
}

- (void)getChat:(id)caller withConversation:(PFObject *)conversation {
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"conversation" equalTo:conversation];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"chat query success with # of chats: %ld", (unsigned long)[objects count]);
        [caller processChatList:objects];
    }];
}

@end