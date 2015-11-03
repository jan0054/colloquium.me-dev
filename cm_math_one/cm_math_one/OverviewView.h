//
//  OverviewView.h
//  cm_math_one
//
//  Created by csjan on 7/22/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+ParseQueries.h"
#import <Parse/Parse.h>

@interface OverviewView : UIViewController
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *timeAndOrganizerBackground;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *organizerButton;
- (IBAction)organizerButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIView *attendanceBackground;
@property (strong, nonatomic) IBOutlet UILabel *attendanceLabel;
@property (strong, nonatomic) IBOutlet UISwitch *attendanceSwitch;
- (IBAction)attendanceSwitchChanged:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UITableView *newsTable;
@property (strong, nonatomic) IBOutlet UILabel *noNewsLabel;


- (void)processEvent: (PFObject *) object;
- (void)processData: (NSArray *) results;
@property UIRefreshControl *pullrefresh;
@end
