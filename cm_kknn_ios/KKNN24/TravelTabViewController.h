//
//  TravelTabViewController.h
//  SQuInt2014
//
//  Created by csjan on 4/17/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VenueCellTableViewCell.h"


@interface TravelTabViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *venuetable;
@property NSMutableArray *venue_array;
- (IBAction)venue_call_tap:(UIButton *)sender;
- (IBAction)venue_navigate_tap:(UIButton *)sender;
- (IBAction)venue_website_tap:(UIButton *)sender;
@property UIRefreshControl *pullrefresh;

- (void)processData: (NSArray *) results;
@end
