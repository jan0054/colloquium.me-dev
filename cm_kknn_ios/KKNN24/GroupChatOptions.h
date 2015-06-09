//
//  GroupChatOptions.h
//  KKNN24
//
//  Created by csjan on 6/9/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatOptions : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *leaveConversationButton;
- (IBAction)leaveConversationButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *addConversationButton;
- (IBAction)addConversationButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *inviteTable;

@end
