//
//  TimelineViewController.h
//  KKNN24
//
//  Created by csjan on 5/19/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *timeline_table;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addpost_button;
- (IBAction)addpost_button_tap:(UIBarButtonItem *)sender;

@property UIRefreshControl *pullrefresh;

@end
