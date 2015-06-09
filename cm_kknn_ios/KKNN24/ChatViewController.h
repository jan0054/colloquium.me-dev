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

@property NSString *conversation_objid;      //required: conversation id to get the chats from
@property NSMutableArray *chat_table_array;  //main array to hold chat objects
@property NSMutableArray *participants;      //chat participant array

//ui
@property (strong, nonatomic) IBOutlet UITextField *chat_input_box;
@property (strong, nonatomic) IBOutlet UIButton *send_chat_button;
- (IBAction)send_chat_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *chat_table;
@property UIRefreshControl *pullrefresh;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textfieldbottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendmessagebottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tablebottom;
@property (strong, nonatomic) IBOutlet UIView *curtainView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
- (IBAction)editButtonTap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIView *optionsContainer;

//data
- (void) processChatUploadWithConversation: (PFObject *)conversation withContent: (NSString *)content;
- (void)processChatList: (NSArray *)results;

@end
