//
//  TimelineViewController.h
//  a_gentle_sunset
//
//  Created by csjan on 3/26/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "PFQueryTableViewController.h"
#import <Parse/Parse.h>
#import <ParseUI.h>

@interface TimelineViewController : PFQueryTableViewController
- (IBAction)new_post_button_tap:(UIBarButtonItem *)sender;

@end
