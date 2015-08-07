//
//  ChatOptions.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatOptions : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *inviteeTabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leaveButton;
- (IBAction)leaveButtonTap:(UIBarButtonItem *)sender;
- (IBAction)inviteButtonTap:(UIButton *)sender;

@property PFObject *conversation;
@property NSMutableArray *receivedParticipants;

@end
