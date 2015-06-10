//
//  GroupChatOptions.h
//  KKNN24
//
//  Created by csjan on 6/9/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol delegateProtocol <NSObject>
- (void) gotParticipantsFromDelegate:(NSArray *)results;
- (void) leaveConversationFromDelegate;
@end
//ui
@interface GroupChatOptions : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *leaveConversationButton;
- (IBAction)leaveConversationButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *addConversationButton;
- (IBAction)addConversationButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *inviteTable;
//passing data
- (void)processInviteeData: (NSArray *)results;
@property id data_delegate;
//data
@property BOOL isGroup;                            //is this conversation a group chat: used to disable "leave conversation" option
@property NSMutableArray *selectedList;            //holds the list of users that are selected from the table
@property NSMutableArray *participants;            //the existing users in this conversation
@property PFObject *conversation;                  //the conversation this chat is taking place in

@end
