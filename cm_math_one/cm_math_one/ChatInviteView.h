//
//  ChatInviteView.h
//  cm_math_one
//
//  Created by csjan on 8/10/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatInviteView : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *chatInviteTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *inviteDoneButton;
- (IBAction)inviteDoneButtonTap:(UIBarButtonItem *)sender;
- (IBAction)inviteButtonTap:(UIButton *)sender;

- (void)processInviteeData:(NSArray *)results;  //category callback
- (void)createConvSuccess;  //category callback

@end
