//
//  AttendeeDetailView.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AttendeeDetailView : UIViewController
@property (strong, nonatomic) IBOutlet UIView *attendeeBackground;
@property (strong, nonatomic) IBOutlet UIView *buttonBarBackground;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *institutionLabel;
@property (strong, nonatomic) IBOutlet UIButton *chatButton;
@property (strong, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) IBOutlet UIButton *websiteButton;
- (IBAction)chatButtonTap:(UIButton *)sender;
- (IBAction)emailButtonTap:(UIButton *)sender;
- (IBAction)websiteButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *attendeeProgramTable;

@property PFObject *attendee;

@end
