//
//  ChooseElderTableViewController.h
//  a_gentle_sunset
//
//  Created by csjan on 4/28/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol selectionDelegate <NSObject>

-(void)getElderList:(NSMutableArray *)elder_list;

@end

@interface ChooseElderTableViewController : UITableViewController
- (IBAction)select_elder_done_tap:(UIBarButtonItem *)sender;

@property id elder_delegate;

@end
