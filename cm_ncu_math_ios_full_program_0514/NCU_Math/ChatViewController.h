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
@property NSString *other_guy_objid;
@property NSString *other_guy_name;
@property PFUser *otherguy;

@property (strong, nonatomic) IBOutlet UITextField *chat_input_box;
@property (strong, nonatomic) IBOutlet UIButton *send_chat_button;
- (IBAction)send_chat_button_tap:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *chat_table;
@property NSMutableArray *chat_array;
@property NSMutableArray *chat_table_array;
@property UIRefreshControl *pullrefresh;
@property NSString *ab_self;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textfieldbottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendmessagebottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tablebottom;

@end
