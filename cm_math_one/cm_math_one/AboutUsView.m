//
//  AboutUsView.m
//  cm_math_one
//
//  Created by csjan on 7/7/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "AboutUsView.h"
#import "UIColor+ProjectColors.h"
#import <Parse/Parse.h>

NSMutableArray *peoplelist;

@interface AboutUsView ()

@end

@implementation AboutUsView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //peoplelist = [[NSMutableArray alloc] init];
    
    //styling
    [self.doneButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
    [self.contactButton setTitleColor:[UIColor dark_accent] forState:UIControlStateNormal];
}

- (IBAction)contactButtonTap:(UIButton *)sender {
    NSLog(@"CONTACT");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://jan0054@gmail.com"]];
    //[self getPersonList];
    //[PFCloud callFunctionInBackground:@"refreshUsers" withParameters:NULL];
}

- (IBAction)doneButtonTap:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//testing stuff to update all people
- (void)getPersonList {
    //PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"last_name"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Person query without search, success with results: %lu", (unsigned long)[objects count]);
        peoplelist = [objects mutableCopy];
        [self processPeople];
    }];
}

- (void)processPeople {
    for (PFUser *person in peoplelist)
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
