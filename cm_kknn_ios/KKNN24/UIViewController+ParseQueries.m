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

- (void)getConversations:(id)caller withPerson:(PFObject *)person {
    PFRelation *relation = [person relationForKey:@"conversation"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"conversation query error");
        } else {
            [caller processData:objects];
        }
    }];
}

@end
