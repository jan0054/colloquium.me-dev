//
//  ChatOptions.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatOptions : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *inviteeTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leaveButton;
- (IBAction)leaveButtonTap:(UIBarButtonItem *)sender;
- (IBAction)inviteButtonTap:(UIButton *)sender;

- (void)processInviteeData:(NSArray *)results;  //category callback
- (void)processAddedSuccess: (NSIndexPath *)path forAddedUser: (PFUser *)user;  //category callback
- (void)processLeftConversation;  //category callback

@property PFObject *conversation;
@property NSMutableArray *receivedParticipants;
@property (strong, nonatomic) IBOutlet UIView *searchBackgroundView;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
- (IBAction)searchButtonTap:(UIButton *)sender;

@end
