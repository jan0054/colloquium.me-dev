//
//  ChatView.h
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ChatView : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *chatTable;
@property (strong, nonatomic) IBOutlet UIView *inputBackground;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendChatButton;
- (IBAction)sendChatButtonTap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
- (IBAction)editButtonTap:(UIBarButtonItem *)sender;

@property PFObject *currentConversation;
@property NSMutableArray *participants;
@property UIRefreshControl *pullrefresh;

//data
- (void) processChatUploadWithConversation: (PFObject *)conversation withContent: (NSString *)content;
- (void)processChatList: (NSArray *)results;

@end
