//
//  PasswordResetView.m
//  cm_math_one
//
//  Created by csjan on 11/2/15.
//  Copyright © 2015 tapgo. All rights reserved.
//

#import "PasswordResetView.h"
#import <Parse/Parse.h>

NSMutableArray *peoplelist;

@implementation PasswordResetView

- (void)viewDidLoad {
    [super viewDidLoad];
    peoplelist = [[NSMutableArray alloc] init];
    //[self getPersonList];
}

//testing stuff to update all people
- (void)getPersonList {
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query orderByAscending:@"last_name"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Person query without search, success with results: %lu", (unsigned long)[objects count]);
        peoplelist = [objects mutableCopy];
        [self processPeople];
    }];
}

- (void)processPeople {
    for (PFObject *person in peoplelist)
    {
        person[@"debug_status"] = @0;
        if (person.save)
        {
            NSLog(@"success:%@", person.objectId);
        }
        else
        {
            NSLog(@"failed:%@", person.objectId);
        }
    }
}

@end
