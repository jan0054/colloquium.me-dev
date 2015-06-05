//
//  ChatViewController.h
//  SQuInt2014
//
//  Created by csjan on 4/21/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ChatViewController : UIViewController<UITextFieldDelegate, UIScrollViewDelegate>
@property NSString *conversation_objid;
@property int is_new_conv;
@property NSMutableArray *chat_table_array;
@property NSMutableArray *participants;

@property (strong, nonatomic) IBOutlet UITextField *chat_input_box;
@property (strong, nonatomic) IBOutlet UIButton *send_chat_button;
- (IBAction)send_chat_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *chat_table;
@property UIRefreshControl *pullrefresh;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textfieldbottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendmessagebottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tablebottom;
- (void) processChatUploadWithConversation: (PFObject *)conversation withContent: (NSString *)content;
- (void)processChatList: (NSArray *)results;

@end
