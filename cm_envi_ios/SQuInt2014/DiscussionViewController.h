//
//  DiscussionViewController.h
//  SQuInT2015
//
//  Created by Chi-sheng Jan on 1/30/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"

@interface DiscussionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *discussion_table;
@property (weak, nonatomic) IBOutlet UITextField *discussion_input;
@property (weak, nonatomic) IBOutlet UIButton *discussion_send_button;
- (IBAction)discussion_send_button_tap:(UIButton *)sender;

@property PFObject *event_obj;
@property NSString *event_objid;
@property int event_type;   //0=talk, 1=poster, 2=attachment/abstract

@property UIRefreshControl *pullrefresh;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *table_bottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textfield_bottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *send_button_bottom;
@property (strong, nonatomic) IBOutlet UILabel *empty_label;

@end
