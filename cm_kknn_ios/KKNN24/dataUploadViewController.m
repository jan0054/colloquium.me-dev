//
//  dataUploadViewController.m
//  SQuInT2015
//
//  Created by csjan on 1/22/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "dataUploadViewController.h"
#import <Parse/Parse.h>

@interface dataUploadViewController ()

@end

NSMutableArray *results;
int counter;

@implementation dataUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    results = [[NSMutableArray alloc] init];
    counter = 100;
    
    PFQuery *posterquery = [PFQuery queryWithClassName:@"person"];
    [posterquery orderByDescending:@"last_name"];
    [posterquery includeKey:@"user"];
    posterquery.limit = 250;
    [posterquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"query success");
        results = [objects mutableCopy];
    }];

    
}


- (IBAction)process:(UIButton *)sender {
    [self runupdate];
    /*
    NSLog(@"GO");
    PFQuery *personquery = [PFQuery queryWithClassName:@"person"];
    [personquery getObjectInBackgroundWithId:@"O9C7fdRDnF" block:^(PFObject *object, NSError *error) {
        object[@"debug"] = 0;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"TEST DONE");
        }];
    }];
     */
}

- (void) runupdate
{
    PFObject *newobj = [results objectAtIndex:counter];
    newobj[@"debug"] = @0;
    

    [newobj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"DONE:%i", counter);
        
         counter = counter +1;
         if (counter <= [results count])
         {
         [self runupdate];
         }
        
    }];
}

@end
