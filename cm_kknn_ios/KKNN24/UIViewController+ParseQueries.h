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
- (void)getPosters: (id)caller;
- (void)getAttachments: (id)caller;
- (void)getPeople: (id)caller withSearch: (NSMutableArray *)searchArray;
- (void)getPosts: (id)caller;
- (void)getConversations: (id)caller withPerson: (PFObject *)person;

@end
