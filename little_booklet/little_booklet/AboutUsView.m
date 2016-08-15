//
//  AboutUsView.m
//  UIUC Taiwan Alumni Club
//
//  Created by csjan on 7/7/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "AboutUsView.h"
#import "UIColor+ProjectColors.h"
#import <Parse/Parse.h>
//#import <Crashlytics/Crashlytics.h>

NSMutableArray *testlist;

@interface AboutUsView ()

@end

@implementation AboutUsView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    testlist = [[NSMutableArray alloc] init];
    
    //styling
    [self.doneButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
    [self.contactButton setTitleColor:[UIColor accent_color] forState:UIControlStateNormal];
}

- (IBAction)contactButtonTap:(UIButton *)sender {
    NSLog(@"CONTACT");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://jan0054@gmail.com"]];
    //[self getTalkList];
    //[PFCloud callFunctionInBackground:@"refreshUsers" withParameters:NULL];
    //[[Crashlytics sharedInstance] crash];
    
}

- (IBAction)doneButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//testing stuff to
- (void)getPersonList {
    //PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"last_name"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Person query without search, success with results: %lu", (unsigned long)[objects count]);
        testlist = [objects mutableCopy];
        [self processPeople];
    }];
}
- (void)getTalkList {
    PFQuery *query = [PFQuery queryWithClassName:@"Talk"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"talk query success with results: %lu", (unsigned long)[objects count]);
        testlist = [objects mutableCopy];
        [self processTalk];
    }];
}


- (void)processPeople {
    for (PFUser *person in testlist)
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
- (void)processTalk {
    for (PFObject *talk in testlist)
    {
        talk[@"debug_status"] = @0;
        if (talk.save)
        {
            NSLog(@"success:%@", talk.objectId);
        }
        else
        {
            NSLog(@"failed:%@", talk.objectId);
        }
    }
}



@end
